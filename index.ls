
angular.module \stockings, <[]>
  .controller \form, <[$scope]> ++ ($scope) ->
    WebFontConfig = do
      timeout: 5000
      custom: do
        families: [ 'Noto Sans TC' ],
        urls: [ 'https://fonts.googleapis.com/earlyaccess/notosanstc.css' ]
      active: -> setTimeout (-> $ \html .add-class \wf-active-later ), 1500
    if WebFont? => WebFont.load WebFontConfig
    smoothScroll.init!

    $scope.price = {gray: 100, azure: 100, black: 100}
    $scope.error = {clear: false}
    $scope.init-info = do
      name: ""
      phone: ""
      addr: ""
      slot: 0
      shipfee: 60
      subtotal: 0
      count: 0
      cart: {gray: 0, azure: 0, black: 0}
      submit: false
    $scope.error = {}
    $scope.check = (submit) ->
      if !$scope.submit and !submit => return
      $scope.submit = true
      $scope.error = {clear: true}
      info = $scope.info
      if !info.name => $scope.error.name = "必填"
      if !info.phone => $scope.error.phone = "必填"
      if !info.addr => $scope.error.addr = "必填"
      if info.count < 3 => $scope.error.count = "購買下限為三雙"
      if $scope.error.name or $scope.error.phone or $scope.error.addr or $scope.error.count =>
        $scope.error.clear = false

    $scope.$watch 'info.cart', (->
      $scope.info.count = <[gray azure black]>.reduce(
        ((a,b) -> +$scope.info.cart[b] + a), 0
      )
      $scope.info.subtotal = <[gray azure black]>.reduce(
        ((a,b) -> $scope.price[b] * +$scope.info.cart[b] + a), 0
      )
      if $scope.info.count => $scope.info.subtotal += $scope.info.shipfee
      $scope.check!
    ), true
    fbref = new Firebase \https://stockings-2f825.firebaseio.com/purchase
    $scope.reset = (jump) ->
      $scope.info = JSON.parse(JSON.stringify($scope.init-info))
      $scope.error = {clear: true}
      $scope.submit = false
      if jump => smoothScroll.animateScroll( document.querySelector \#a-form )
    $scope.purchase = ->
      $scope.check true
      if !$scope.error.clear => return
      $scope.info.loading = true
      payload = JSON.parse(JSON.stringify($scope.info))
      (e) <- fbref.push payload, _
      if e => console.log e
      <- $scope.$apply
      $scope.info.loading = false
      $scope.info.done = true
      fbq('track', 'Purchase', {value: "#{$scope.info.subtotal}", currency:'TWD'});
      smoothScroll.animateScroll( document.querySelector \#a-reset )
    $scope.reset!
