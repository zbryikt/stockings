WebFontConfig = do
  timeout: 5000
  custom: do
    families: [ 'Noto Sans TC' ],
    urls: [ 'https://fonts.googleapis.com/earlyaccess/notosanstc.css' ]
  active: -> setTimeout (-> $ \html .add-class \wf-active-later ), 1500
WebFont.load WebFontConfig

smoothScroll.init!
