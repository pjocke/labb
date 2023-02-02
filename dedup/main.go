package main

import (
	"crypto/md5"
	"fmt"
	"io/fs"
	"os"
	"syscall"

	"github.com/Moby/moby/pkg/namesgenerator"
)

func deduplicate(path string, inodes *map[uint64]bool, hashes *map[string]string) error {
	var err error
	var f *os.File

	// Open directory
	f, err = os.Open(path)
	if err != nil {
		return err
	}
	defer f.Close()

	// Read directory
	var entries []fs.DirEntry
	entries, err = f.ReadDir(0)
	if err != nil {
		return err
	}

	// Read files in directory
	var entry fs.DirEntry
	for _, entry = range entries {
		if entry.Type().IsDir() {
			// Found sub-directory, recurse
			deduplicate(path+"/"+entry.Name(), inodes, hashes)
		} else if entry.Type().IsRegular() {
			// Get inode for file
			var info fs.FileInfo
			info, err = entry.Info()
			if err != nil {
				return err
			}
			var inode uint64 = info.Sys().(*syscall.Stat_t).Ino

			// Check inode cache
			var ok bool
			_, ok = (*inodes)[inode]
			if ok {
				// Seen before
				continue
			} else {
				// Not seen before

				// Cache inode
				(*inodes)[inode] = true

				// Compute hash for file
				var data []byte
				data, err = os.ReadFile(path + "/" + entry.Name())
				if err != nil {
					return err
				}
				var hash string
				hash = fmt.Sprintf("%s", md5.Sum(data))

				// Check hash cache
				_, ok = (*hashes)[hash]
				if ok {
					// Duplicate

					// Generate temporary file name
					var tmp string
					for {
						tmp = namesgenerator.GetRandomName(16)
						_, err = os.Stat(path + "/" + tmp)
						if err != nil && os.IsNotExist(err) {
							break
						}
					}

					// Create hard link to original using temporary name
					err = os.Link((*hashes)[hash], path+"/"+tmp)
					if err != nil {
						return err
					}

					// Rename symlink to original
					os.Rename(path+"/"+tmp, path+"/"+entry.Name())
				} else {
					// Not duplicate

					//cache hash
					(*hashes)[hash] = path + "/" + entry.Name()
				}
			}
		}
	}

	return nil
}

func main() {
	var inodes map[uint64]bool = make(map[uint64]bool)
	var hashes map[string]string = make(map[string]string)

	var err error
	err = deduplicate("/home/joakimbomelin/src/github.com/pjocke/labb/dedup/data", &inodes, &hashes)
	if err != nil {
		fmt.Println(err.Error())
		os.Exit(1)
	}
}
