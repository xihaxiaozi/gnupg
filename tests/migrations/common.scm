;; Copyright (C) 2016 g10 Code GmbH
;;
;; This file is part of GnuPG.
;;
;; GnuPG is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3 of the License, or
;; (at your option) any later version.
;;
;; GnuPG is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program; if not, see <http://www.gnu.org/licenses/>.

(if (string=? "" (getenv "srcdir"))
    (error "not called from make"))

(setenv "GNUPGHOME" "" #t)

(define (qualify executable)
  (string-append executable (getenv "EXEEXT")))

;; We may not use a relative name for gpg-agent.
(define GPG-AGENT (qualify (string-append (getcwd) "/../../agent/gpg-agent")))
(define GPG `(,(qualify (string-append (getcwd) "/../../g10/gpg"))
	      --no-permission-warning --no-greeting
	      --no-secmem-warning --batch
	      ,(string-append "--agent-program=" GPG-AGENT
			      "|--debug-quick-random")))

(define (dearmor source-name sink-name)
  (pipe:do
   (pipe:open source-name (logior O_RDONLY O_BINARY))
   (pipe:spawn `(,@GPG --dearmor))
   (pipe:write-to sink-name
		  (logior O_WRONLY O_CREAT O_BINARY)
		  #o600)))
