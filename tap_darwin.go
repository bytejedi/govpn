//go:build darwin

/*
GoVPN -- simple secure free software virtual private network daemon
Copyright (C) 2022 github.com/bytejedi
*/

package govpn

import (
	"io"

	"github.com/songgao/water"
)

func newTAPer(_ string) (io.ReadWriter, error) {
	return water.New(water.Config{
		DeviceType: water.TUN,
	})
}
