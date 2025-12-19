(import ../jipper :as j)

# XXX: using `path` and `leftmost` might be better?

# checking whether something is a top-level tuple
(comment

  (def an-import
    "(import ./analyze :as a)")

  (def a-zloc
    (j/zip-down (j/par an-import)))

  (j/node a-zloc)
  # =>
  [:tuple @{:bc 1 :bl 1 :ec 25 :el 1}
   [:symbol @{:bc 2 :bl 1 :ec 8 :el 1} "import"]
   [:whitespace @{:bc 8 :bl 1 :ec 9 :el 1} " "]
   [:symbol @{:bc 9 :bl 1 :ec 18 :el 1} "./analyze"]
   [:whitespace @{:bc 18 :bl 1 :ec 19 :el 1} " "]
   [:keyword @{:bc 19 :bl 1 :ec 22 :el 1} ":as"]
   [:whitespace @{:bc 22 :bl 1 :ec 23 :el 1} " "]
   [:symbol @{:bc 23 :bl 1 :ec 24 :el 1} "a"]]

  (= :code
     (get (j/node (j/up a-zloc)) 0))
  # =>
  true

  # at top-level syntactically
  (length (j/path a-zloc))
  # =>
  1

  (def upscoped
    "(upscope (def a 1))")

  (def u-zloc
    (j/zip-down (j/par upscoped)))

  (j/node u-zloc)
  # =>
  [:tuple @{:bc 1 :bl 1 :ec 20 :el 1}
   [:symbol @{:bc 2 :bl 1 :ec 9 :el 1} "upscope"]
   [:whitespace @{:bc 9 :bl 1 :ec 10 :el 1} " "]
   [:tuple @{:bc 10 :bl 1 :ec 19 :el 1}
    [:symbol @{:bc 11 :bl 1 :ec 14 :el 1} "def"]
    [:whitespace @{:bc 14 :bl 1 :ec 15 :el 1} " "]
    [:symbol @{:bc 15 :bl 1 :ec 16 :el 1} "a"]
    [:whitespace @{:bc 16 :bl 1 :ec 17 :el 1} " "]
    [:number @{:bc 17 :bl 1 :ec 18 :el 1} "1"]]]

  (def def-zloc
    (-> u-zloc
        j/down
        j/right-skip-wsc))

  (j/node def-zloc)
  # =>
  [:tuple @{:bc 10 :bl 1 :ec 19 :el 1}
   [:symbol @{:bc 11 :bl 1 :ec 14 :el 1} "def"]
   [:whitespace @{:bc 14 :bl 1 :ec 15 :el 1} " "]
   [:symbol @{:bc 15 :bl 1 :ec 16 :el 1} "a"]
   [:whitespace @{:bc 16 :bl 1 :ec 17 :el 1} " "]
   [:number @{:bc 17 :bl 1 :ec 18 :el 1} "1"]]

  # not at top-level syntactically
  (length (j/path def-zloc))
  # =>
  2

  )

# checking if something is effectively a top-level tuple
(comment

  (def a-def
    "(def a 1)")

  (def a-comment-opener
    "(comment\n")

  (def a-comment-closer
    "  )")

  (def a-comment-form
    (string a-comment-opener
            "\n"
            a-def "\n"
            "\n"
            a-comment-closer))

  (def b-zloc
    (-> (j/zip-down (j/par a-comment-form))
        (j/search-after |(match (j/node $) [:tuple] $))))

  (j/node b-zloc)
  # =>
  [:tuple @{:bc 1 :bl 3 :ec 10 :el 3}
   [:symbol @{:bc 2 :bl 3 :ec 5 :el 3} "def"]
   [:whitespace @{:bc 5 :bl 3 :ec 6 :el 3} " "]
   [:symbol @{:bc 6 :bl 3 :ec 7 :el 3} "a"]
   [:whitespace @{:bc 7 :bl 3 :ec 8 :el 3} " "]
   [:number @{:bc 8 :bl 3 :ec 9 :el 3} "1"]]

  (def c-zloc
    (j/up b-zloc))

  (when-let [c-node (j/node c-zloc)
             head-zloc (j/down c-zloc)
             head-node (j/node head-zloc)]
    (and (= :tuple (get c-node 0))
         (or # XXX: this part is not quite right if there is some
             #      non-whitespace / non-comment thing that occurs
             #      as the "head" element instead
             (and (= :symbol (get head-node 0))
                  (= "comment" (get head-node 2)))
             (when-let [non-wsc-node (j/right-skip-wsc head-node)]
               (and (= :symbol (get head-node 0))
                    (= "comment" (get head-node 2)))))))
  # =>
  true

  (= :code
     (get (j/node (j/up (j/up b-zloc))) 0))
  # =>
  true

  )

