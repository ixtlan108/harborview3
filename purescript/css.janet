

(def sass-home "/home/rcs/opt/java/harborview3/sass-src")

(defn file-name-for (css-import)
  (let (s (string/split " " css-import)
        s1 (string/trim (get s 1)))
    s1))


(defn css-file (pkg file-name)
  (let (css-path (string/slice (buffer/push-string @"" sass-home "/" pkg "/" file-name ".scss")))
    (file/open css-path :r)))

(defn import-file (pkg fname)
  (let (f (css-file pkg fname)
        iter (file/lines f))
    (each val iter
      (pp val))))


(defn run ()
  (let (f (css-file "rapanui" "rapanui") 
        iterator (file/lines f))
    (pp f)
    (each val iterator
      (if (peg/match "import" val)
        (do
          (print val)
          (let (s (file-name-for val))
            (pp s)))))
    (file/close f)))
    
    

(run)
