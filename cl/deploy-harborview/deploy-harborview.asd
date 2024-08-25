(defsystem "deploy-harborview"
  :version "0.9.0"
  :author ""
  :license ""
  :depends-on ("str")
  :components ((:module "src"
                :components
                 ((:file "main"))))
  :description ""
  :in-order-to ((test-op (test-op "deploy-harborview/tests"))))

(defsystem "deploy-harborview/tests"
  :author ""
  :license ""
  :depends-on ("deploy-harborview"
               "rove")
  :components ((:module "t"
                :components
                ((:file "main-test")
                )))
  :description "Test system for deploy"
  :perform (test-op (op c) (symbol-call :rove :run c)))
