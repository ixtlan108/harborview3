(defpackage deploy-harborview/tests/main-test
  (:use :cl
        :rove)
    (:local-nicknames (#:m #:main)))

(in-package :deploy-harborview/tests/main-test)

(defvar *tpl* "../cl/deploy-harborview/t/resources/rigaphoto-482af713.css")

(defvar *spago-cmd* 
  (list "spago" "bundle" "--package" "rigaphoto-app" "--source-maps" "--module" "RigaPhotoMain" "--outfile" "dist/rigaphoto.js"))

(defvar *sass-cmd* 
  (list "sass" "../sass-src/rigaphoto/rigaphoto.scss" "rigaphoto-app/dist/rigaphoto.css"))

(deftest test-config
  (let* ((cfg (m::rigaphoto))
         (spago (m::spago-cfg cfg))
         (sass (m::sass-cfg cfg))
         (spago-pkg (getf spago :pkg)))
    (testing "Riga Photo Config"
      (ok (equal spago-pkg "rigaphoto-app"))
      (ok (equal (getf sass :pkg) "rigaphoto")))
    (testing "Spago Command"
      (ok (equal (m::spago-cmd spago) *spago-cmd*)))
    (testing "Sass Command"
      (ok (equal (m::sass-cmd sass spago-pkg) *sass-cmd*)))))

(deftest test-md5
  (testing "Md5"
    (ok (equal (m::md5 *tpl*) "482af713")))
  (testing "Md5 MacOS"
    (ok (equal (m::md5 *tpl*) "482af713"))))