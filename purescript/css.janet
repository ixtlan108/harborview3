

(def sass-home "/home/rcs/opt/java/harborview3/sass-src")

(defn file-name-for (css-import)
  (let (s (string/split " " css-import)
        s1 (string/trim (get s 1)))
    s1))


(defn css-path (file-name)
  (string/slice 
    (buffer/push-string @"" sass-home "/" file-name ".scss")))

(defn css-file (file-name)
  (let (cp (css-path file-name))
    (pp cp)
    (file/open cp :r)))

(defn import-file (fname)
  (let (f (css-file fname)
        iter (file/lines f))
    (each val iter
      (pp val))
    (file/close f)))


(defn run ()
  (let (f (css-file "rapanui/rapanui") 
        iter (file/lines f))
    (each val iter
      (if (peg/match "import" val)
        (let (s (file-name-for val))
           (import-file s))))
    (file/close f)))
    
    

(run)
