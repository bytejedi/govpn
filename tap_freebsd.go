//go:build freebsd
// +build freebsd

/*
GoVPN -- simple secure free software virtual private network daemon
Copyright (C) 2014-2022 Sergey Matveev <stargrave@stargrave.org>
Copyright (C) 2022 github.com/bytejedi
*/

package govpn

import (
	"io"
	"os"
	"path"
)

func newTAPer(ifaceName string) (io.ReadWriter, error) {
	return os.OpenFile(path.Join("/dev/", ifaceName), os.O_RDWR, os.ModePerm)
}
