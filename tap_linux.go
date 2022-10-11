//go:build linux

/*
GoVPN -- simple secure free software virtual private network daemon
Copyright (C) 2014-2022 Sergey Matveev <stargrave@stargrave.org>
Copyright (C) 2022 github.com/bytejedi
*/

package govpn

import (
	"io"
	"strings"

	"github.com/songgao/water"
)

func newTAPer(ifaceName string) (io.ReadWriter, error) {
	var cfg water.Config
	if strings.HasPrefix(ifaceName, "tap") {
		cfg.DeviceType = water.TAP
	} else {
		cfg.DeviceType = water.TUN
	}
	cfg.Name = ifaceName
	return water.New(cfg)
}
