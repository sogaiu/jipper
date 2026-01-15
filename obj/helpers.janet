# based on code by corasaurus-hex

# `slice` doesn't necessarily preserve the input type

# XXX: differs from clojure's behavior
#      e.g. (butlast [:a]) would yield nil(?!) in clojure
(defn h/butlast
  [indexed]
  (if (empty? indexed)
    nil
    (if (tuple? indexed)
      (tuple/slice indexed 0 -2)
      (array/slice indexed 0 -2))))

(comment

  (h/butlast @[:a :b :c])
  # =>
  @[:a :b]

  (h/butlast [:a])
  # =>
  []

  )

(defn h/rest
  [indexed]
  (if (empty? indexed)
    nil
    (if (tuple? indexed)
      (tuple/slice indexed 1 -1)
      (array/slice indexed 1 -1))))

(comment

  (h/rest [:a :b :c])
  # =>
  [:b :c]

  (h/rest @[:a])
  # =>
  @[]

  )

# XXX: can pass in array - will get back tuple
(defn h/tuple-push
  [tup x & xs]
  (if tup
    [;tup x ;xs]
    [x ;xs]))

(comment

  (h/tuple-push [:a :b] :c)
  # =>
  [:a :b :c]

  (h/tuple-push nil :a)
  # =>
  [:a]

  (h/tuple-push @[] :a)
  # =>
  [:a]

  )

(defn h/to-entries
  [val]
  (if (dictionary? val)
    (pairs val)
    val))

(comment

  (sort (h/to-entries {:a 1 :b 2}))
  # =>
  @[[:a 1] [:b 2]]

  (h/to-entries {})
  # =>
  @[]

  (h/to-entries @{:a 1})
  # =>
  @[[:a 1]]

  # XXX: leaving non-dictionaries alone and passing through...
  #      is this desirable over erroring?
  (h/to-entries [:a :b :c])
  # =>
  [:a :b :c]

  )

# XXX: when xs is empty, "all" becomes nil
(defn h/first-rest-maybe-all
  [xs]
  (if (or (nil? xs) (empty? xs))
    [nil nil nil]
    [(first xs) (h/rest xs) xs]))

(comment

  (h/first-rest-maybe-all [:a :b])
  # =>
  [:a [:b] [:a :b]]

  (h/first-rest-maybe-all @[:a])
  # =>
  [:a @[] @[:a]]

  (h/first-rest-maybe-all [])
  # =>
  [nil nil nil]

  # XXX: is this what we want?
  (h/first-rest-maybe-all nil)
  # =>
  [nil nil nil]

  )

