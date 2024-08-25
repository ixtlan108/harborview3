(defpackage main
  (:use :cl))

(in-package :main)

;(defparameter nvm "/home/rcs/.nvm/versions/node/v16.20.2/bin")
;(defparameter spago (concatenate 'string nvm "/spago"))
;(defparameter sass (concatenate 'string nvm "/sass"))

;(defparameter sass-src "/home/rcs/opt/klaxton/PhotoAppMVC/sass-src")

(defun md5klaxton (file-name)
  "klaxton")

(defun md5 (file-name)
  (let* ((m (uiop:run-program (list "md5sum" file-name) :output :string)))
    (subseq m 0 8)))

(defvar *md5* #'md5)
(defvar *gen-sass* t)
(defvar *gen-spago* t)

; Mac OS -> "MD5 (/Users/zeus/Projects/PhotoAppMVC/cl/deploy-ps/t/resources/rigaphoto-482af713.css) = 482af7137144614ed3535474843429f3"

(defun maunaloa()
  (let ((spago (list 
                  :pkg "maunaloa"
                  :module "Main"
                  :target "dist/ps-charts.js"
                  :js-file "maunaloa/dist/ps-charts.js"
                  :js-map-file "../src/main/resources/static/js/maunaloa/maunaloa.js.map"
                  :js-target "../src/main/resources/static/js/maunaloa/ps-charts-~a.js"))
        (sass (list 
                  :src "../sass-src" 
                  :pkg "maunaloa" 
                  :scss-file "maunaloa.scss"
                  :css-file "maunaloa.css"
                  :css-file-2 "maunaloa/dist/maunaloa.css"
                  :css-map-file "maunaloa/dist/maunaloa.css.map"
                  :css-map-target"../src/main/resources/static/css/maunaloa/maunaloa.css.map"
                  :css-target "../src/main/resources/static/css/maunaloa/maunaloa-~a.css")))
    (list :spago spago 
          :sass sass 
          :tpl "maunaloa/tpl/charts.html.tpl"
          :tpl-target "../src/main/resources/templates/maunaloa/charts.html")))

(defun rapanui()
  (let ((spago (list 
                  :pkg "rapanui"
                  :module "RapanuiMain"
                  :target "dist/rapanui.js"
                  :js-file "rapanui/dist/rapanui.js"
                  :js-map-file "../src/main/resources/static/js/rapanui/rapanui.js.map"
                  :js-target "../src/main/resources/static/js/rapanui/rapanui-~a.js"))
        (sass (list 
                  :src "../sass-src" 
                  :pkg "rapanui" 
                  :scss-file "rapanui.scss"
                  :css-file "rapanui.css"
                  :css-file-2 "rapanui/dist/rapanui.css"
                  :css-map-file "rapanui/dist/rapanui.css.map"
                  :css-map-target"../src/main/resources/static/css/rapanui/rapanui.css.map"
                  :css-target "../src/main/resources/static/css/rapanui/rapanui-~a.css")))
    (list :spago spago 
          :sass sass 
          :tpl "rapanui/tpl/rapanui.html.tpl"
          :tpl-target "../src/main/resources/templates/rapanui/rapanui.html")))

(defun spago-cfg (cfg)
  (getf cfg :spago))

(defun sass-cfg (cfg)
  (getf cfg :sass))

(defun spago-cmd (cfg)
  (let ((pkg (getf cfg :pkg))
        (main-module (getf cfg :module))
        (target (getf cfg :target)))
    (list "spago" "bundle" "--package" pkg "--source-maps" "--module" main-module "--outfile" target)))

(defun run-spago (cfg)
  (let* ((sp (spago-cfg cfg))
         (cmd (spago-cmd sp))
         (js (getf sp :js-file)))
    (if *gen-spago* 
      (progn 
        (print "************ run-spago ************")
        (finish-output)
        (uiop:run-program cmd :output t)))
    (funcall *md5* js)))

(defun sass-cmd (cfg spago-pkg)
  (let* ((src (getf cfg :src))
         (pkg (getf cfg :pkg))
         (scss (getf cfg :scss-file))
         (css (getf cfg :css-file))
         (out-file (format nil "~a/dist/~a" spago-pkg css)))
    (list "sass" (format nil "~a/~a/~a" src pkg scss) out-file)))
      
(defun run-sass (cfg)
  (let* ((sc (sass-cfg cfg))
         (sp (spago-cfg cfg))
         (spago-pkg (getf sp :pkg))
         (css (getf sc :css-file))
         (cmd (sass-cmd sc spago-pkg))
         (out-file (format nil "~a/dist/~a" spago-pkg css)))
         ;(my-md5 (funcall *md5* out-file)))
    (if *gen-sass* 
      (progn 
        (print "************ run-sass ************")
        (finish-output)
        (uiop:run-program cmd :output t)))
    (funcall *md5* out-file)))

;(defun render-tpl (tpl tpl-target spago-md5 sass-md5)

(defun render-tpl (cfg spago-md5 sass-md5)
  (let* ((tpl (getf cfg :tpl))
         (target (getf cfg :tpl-target))
         (content (uiop:read-file-string tpl))
         (tpl-result (format nil content spago-md5 sass-md5)))
    (print "render-tpl")
    (with-open-file (stream target :direction :output :if-exists :supersede)
      (write-string tpl-result stream))))

(defconstant LOFSRUD 1)
(defconstant STUDIOP 2)

(defun run (cfg &key (loc LOFSRUD) (sass t) (spago t))
  (let* ((*md5* (if (= loc LOFSRUD) #'md5 #'md5klaxton))
        (*gen-sass* sass)
        (*gen-spago* spago)
        (spago-md5 (run-spago cfg))
        (sass-md5 (run-sass cfg))
        (sp (spago-cfg cfg))
        (js (getf sp :js-file))
        (js-map (getf sp :js-map-file))
        (js-target (getf sp :js-target))
        (sc (sass-cfg cfg))
        (css (getf sc :css-file))
        (css-2 (getf sc :css-file-2))
        (css-mf (getf sc :css-map-file))
        (css-mt (getf sc :css-map-target))
        (css-target (getf sc :css-target)))
    (print "run")
    (render-tpl cfg spago-md5 sass-md5)
    (print "copy-file js")
    (uiop:copy-file js (format nil js-target spago-md5))
    (print "copy-file js.map")
    (uiop:copy-file (concatenate 'string js ".map") js-map)
    (print "copy-file css")
    (uiop:copy-file css-2 (format nil css-target sass-md5))
    (print "copy-file css.map")
    (uiop:copy-file css-mf css-mt)))

(defun run-maunaloa ()
  (run (maunaloa) :loc LOFSRUD :sass t :spago t))
  
(defun run-maunaloa-spago ()
  (run (maunaloa) :loc LOFSRUD :sass nil :spago t))
  
(defun run-maunaloa-sass ()
  (run (maunaloa) :loc LOFSRUD :sass t :spago nil))
  
(defun run-rapanui ()
  (run (rapanui) :loc LOFSRUD :sass t :spago t))

(defun run-rapanui-spago ()
  (run (rapanui) :loc LOFSRUD :sass nil :spago t))

(defun run-rapanui-sass ()
  (run (rapanui) :loc LOFSRUD :sass t :spago nil))

(defun x () (print "Hi"))

;(uiop:run-program '("md5sum" "/home/rcs/opt/klaxton/PhotoAppMVC/Purescript/rigaphoto-app/dist/rigaphoto.css") :output :string)

;(uiop:run-program '("/home/rcs/.nvm/versions/node/v16.20.2/bin/sass" "/home/rcs/opt/java/harborview3/sass-src/rapanui/rapanui.scss") :output "/home/rcs/opt/java/harborview3/lisp-sass"  :error-output t)

;(defparameter tpl (uiop:read-file-string "/home/rcs/opt/klaxton/PhotoAppMVC/Python/tpl/rigaphoto-app/index.html.tpl"))

;(defparameter index (format nil tpl "rigaphoto.js" "rigaphoto.css"))

;(uiop:run-program '("/home/rcs/.nvm/versions/node/v16.20.2/bin/spago" "bundle" "--package" "rigaphoto-app" "--module" "RigaPhotoMain" "--outfile" "dist/rigaphoto.js"))

;(uiop:run-program "ls -latr rigaphoto-app/dist")
