angular.module \stockings, <[]>
  ..service \stocks, <[$rootScope]> ++ ($rootScope) ->
    ret = do
      stocks: {}
      consumed: {}
      remains: {}
      options: {}
      choices: {}
    calc = ->
      ret.remains = JSON.parse(JSON.stringify(ret.stocks))
      for key,item of ret.consumed =>
        for stockid,consumed of item => 
          for variant,quantity of consumed =>
            ret.remains{}[stockid].quantity[variant] = (ret.remains{}[stockid].{}quantity[variant] or 0) - quantity
            if ret.remains{}[stockid].{}quantity[variant] < 0 => ret.remains[stockid].quantity[variant] = 0
      for stockid, item of ret.stocks =>
        ret.options[stockid] = {}
        ret.choices[stockid] = {}
        for variant of item.quantity =>
          ret.options[stockid][variant] = [{count: i} for i from 0 to ret.remains[stockid].quantity[variant]]
          if !ret.choices[stockid][variant] => ret.choices[stockid][variant] = ret.options[stockid][variant].0
          else
            if ret.choices[stockid][variant].count < ret.options[stockid][variant].length =>
              ret.choices[stockid][variant] = ret.options[stockid][variant][ret.choices[stockid][variant]].count
            else ret.choices[stockid][variant] = ret.options[stockid][variant][* - 1]


    fbref = do
      stocks: new Firebase "https://stockings-2f825.firebaseio.com/stocks"
      consumed: new Firebase "https://stockings-2f825.firebaseio.com/consumed"
    fbref.stocks.on \value, (obj) ->
      setTimeout (->
        <- $rootScope.$apply
        ret.stocks = obj.val! or {}
        calc!
      ), 0
    fbref.consumed.on \value, (obj) ->
      setTimeout (->
        <- $rootScope.$apply
        ret.consumed = obj.val! or {}
        calc!
      ), 0
    ret
  ..controller \form, <[$scope stocks]> ++ ($scope, stocks) ->
    $scope.stocks = stocks
    $scope.ctrl = {}
    fbref = do
      orders: new Firebase "https://stockings-2f825.firebaseio.com/orders"
      consumed: new Firebase "https://stockings-2f825.firebaseio.com/consumed"
    $scope.form = do
      init: ->
        @reset!
        $scope.$watch 'stocks.choices', (~>
          choices = $scope.stocks.choices
          @order = []
          @subtotal = 0 
          @amount = 0
          for stockid, hash of choices =>
            for variant, val of hash =>
              if !val.count => continue
              @order.push {stockid: stockid, variant: variant, quantity: val.count}
              @amount += val.count
              @subtotal += (val.count * $scope.stocks.stocks[stockid].price[variant])
          if @subtotal => @subtotal += 60 # shipment fee
          $scope.form.check!
        ), true
      reset: (scroll = false) ->
        @ <<< {slot: 0, name: "", phone: "", addr: "", order: [], amount: 0, subtotal: 0, error: null}
        $scope.ctrl <<< {loading: false, done: false, checking: false}
        if scroll => smoothScroll.animateScroll( document.querySelector \#a-form )
      check: ->
        if !$scope.ctrl.checking => return
        @error = null
        if !@name => @{}error.name = "必填"
        if !@phone => @{}error.phone = "必填"
        if !@addr => @{}error.addr = "必填"
        if !@subtotal => @{}error.subtotal = "您尚未選取商品"
      submit: ->
        $scope.ctrl.checking = true
        @check!
        if @error => return
        $scope.ctrl <<< {checking: false, loading: true}
        payload = angular.fromJson(angular.toJson($scope.form{name, phone, addr, subtotal, amount, order}))
        count = {}
        for item in @order => count{}[item.stockid][item.variant] = item.quantity
        (e) <- fbref.consumed.push count
        (e) <- fbref.orders.push payload, _
        $scope.$apply -> $scope.ctrl <<< {loading: false, done: true, checking: false}
        fbq('track', 'Purchase', {value: "#{$scope.form.subtotal}", currency:'TWD'})
        #smoothScroll.animateScroll( document.querySelector \#a-reset )
    $scope.form.init!
