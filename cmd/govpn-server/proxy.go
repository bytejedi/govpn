/*
GoVPN -- simple secure free software virtual private network daemon
Copyright (C) 2014-2022 Sergey Matveev <stargrave@stargrave.org>
Copyright (C) 2022 github.com/bytejedi

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, version 3 of the License.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

package main

import (
	"net/http"

	"github.com/bytejedi/govpn"
)

type proxyHandler struct{}

func (p proxyHandler) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	conn, _, err := w.(http.Hijacker).Hijack()
	if err != nil {
		govpn.Printf(`[proxy-hijack-failed bind="%s" err="%s"]`, *bindAddr, err)
		return
	}
	conn.Write([]byte("HTTP/1.0 200 OK\n\n"))
	go handleTCP(conn)
}

func proxyStart() {
	govpn.BothPrintf(`[proxy-listen bind="%s" addr="%s"]`, *bindAddr, *proxy)
	s := &http.Server{
		Addr:    *proxy,
		Handler: proxyHandler{},
	}
	govpn.BothPrintf(`[proxy-finished bind="%s" result="%s"]`, *bindAddr, s.ListenAndServe())
}
