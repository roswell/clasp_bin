#!/bin/sh
set -e
mkdir -p "/tmp/some dir"
tar xzf $1 -C "/tmp/some dir"
B=`echo "/tmp/some dir"/clasp-*/build/boehmprecise/iclasp`
cat > /tmp/t.lisp <<'EOL'
(defun tak (x y z) (if (not (< y x)) z (tak (tak (1- x) y z) (tak (1- y) z x) (tak (1- z) x y))))
(defun run ()
  (handler-case (error "boom") (error (e) (format t "caught:~a~%" e)))
  (format t "tak=~a~%" (tak 18 12 6)))
EOL
"$B" --version
"$B" --non-interactive --eval '(require :asdf)' --eval '(load (compile-file "/tmp/t.lisp"))' --eval '(run)' \
  --eval '(progn (princ (asdf:asdf-version)) (terpri))' > /tmp/out.txt 2>&1 || (cat /tmp/out.txt; exit 1)
tail -3 /tmp/out.txt
grep -q '^caught:boom$' /tmp/out.txt
grep -q '^tak=7$' /tmp/out.txt
