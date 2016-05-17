<html>
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<link rel="stylesheet" href="https://stackedit.io/res-min/themes/base.css" />
<script type="text/javascript" src="https://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-AMS_HTML"></script>
</head>
<body><div class="container"><h1 id="介紹與特色">介紹與特色</h1>

<h4>TaipeiAPI 是串接台北市政府 <em>Open data API</em> 的程式庫，獲取台北市政府的捷運施工資訊，並在 <strong>MapView</strong> 上用 <strong>Annotation</strong> 標明各個施工地點的位置。當使用者點擊任意一個施工地點的 <strong>Annotation</strong> 時，APP 下方會計算出使用者的目前位置與所選的施工地點之間的<strong>距離</strong>以及<strong>預估開車會到達的時間</strong>，而在點選 <strong>Annotation</strong> 上的 <strong>Detail Button</strong> 時，會顯示使用者所選的施工地點的詳細資訊</h4>

<p><img src="http://i.imgur.com/8s6nQJ6.png" alt="" title="" width= "200px"> 
<img src="http://i.imgur.com/daDnNme.png" alt="" title="" width= "200px"> 
<img src="http://i.imgur.com/gNH4pNF.png" alt="" title="" width= "200px">
<img src="http://i.imgur.com/SWsrxNZ.png" alt="" title="" width= "200px"></p>

<hr>

<p><div class="toc">
<ul>
<li><a href="#架構與實作方法">架構與實作方法</a><ul>
<li><a href="#cocoapod-套件管理"> CocoaPod 套件管理</a><ul>
<li><a href="#step-1-http-request">  Step 1. - HTTP Request</a></li>
<li><a href="#step-2-parse-json">Step 2. - Parse JSON</a></li>
<li><a href="#step-3-storyboard-mapview-and-detailview"> Step 3. - Storyboard : MapView and DetailView</a></li>
<li><a href="#step-4-delegate-mapviewdelegate">Step 4. - Delegate - MapViewDelegate</a></li>
<li><a href="#step-5-segue-prepareforsegue"> Step 5.  Segue - PrepareForSegue</a></li>
</ul>
</li>
</ul>
</li>
</ul>
</li>
</ul>
</div>
</p>

<h2 id="架構與實作方法">架構與實作方法</h2>




<h3 id="cocoapod-套件管理"><i class="icon-folder-open"></i> CocoaPod 套件管理</h3>

<p>由於 TaipeiAPI 有使用到第三方的套件，像是 <strong>Alamofire</strong> 與 <strong>SwiftyJSON</strong> 等等，故使用 CocoaPod 來管理這些套件</p>

<blockquote>
  <p><strong>Note：</strong> run <code>$ pod install</code>  first</p>
</blockquote>

<hr>



<h4 id="step-1-http-request"><i class="icon-file"></i>  Step 1. - HTTP Request</h4>

<p>在 api 串接的部分，首先建了繼承自 <strong>URLRequestConvertible</strong> 協定的 enum:  <strong>Router</strong>，裡面有一個 static property :  <strong>baseURLString</strong></p>



<pre class="prettyprint"><code class=" hljs vbnet"><span class="hljs-keyword">static</span> <span class="hljs-keyword">let</span> baseURLString : <span class="hljs-built_in">String</span></code></pre>

<p>與兩個computed property : </p>

<ul>
<li><strong>method</strong> : 定義API的方式 （GET, POST, PUT …)</li>
<li><strong>path</strong> : 定義API不同的PATH</li>
</ul>



<pre class="prettyprint"><code class=" hljs r">var method: Alamofire.Method{
        <span class="hljs-keyword">switch</span> self {
        case .APICase(let API):
            <span class="hljs-keyword">switch</span> API {
            case .Function:
                <span class="hljs-keyword">return</span> <span class="hljs-keyword">...</span>
            }
        }
    }</code></pre>



<pre class="prettyprint"><code class=" hljs r">var path: String{
        <span class="hljs-keyword">switch</span> self {
        case .APICase(let API):
            <span class="hljs-keyword">switch</span> API {
            case .Function:
                <span class="hljs-keyword">return</span> <span class="hljs-keyword">...</span>
            }
        }
    }</code></pre>

<p>並且 <strong>Router</strong> 裡也定義了 enum 底下不同的 api case 所回傳對應的 request</p>



<pre class="prettyprint"><code class=" hljs cs"><span class="hljs-keyword">var</span> URLRequest: NSMutableURLRequest{
    <span class="hljs-keyword">let</span> mutableURLRequest = NSMutableURLRequest(URL: url)
        <span class="hljs-keyword">switch</span> self {
        <span class="hljs-keyword">case</span> .APICase(<span class="hljs-keyword">let</span> API):
            <span class="hljs-keyword">switch</span> API {
            <span class="hljs-keyword">case</span> .Function :
                    .
                    .
                    .
                <span class="hljs-keyword">return</span> mutableURLRequest
            }
        }

    }</code></pre>

<p>最後，當需要串接 api 時，由 <strong>ServerManager</strong> 來發出 HTTP request</p>



<pre class="prettyprint"><code class=" hljs r">Alamofire.request(api).responseJSON { (response) <span class="hljs-keyword">in</span>
    <span class="hljs-keyword">switch</span> response.result {
            case .Success(let value): <span class="hljs-keyword">...</span>
            case .Failure(let error): <span class="hljs-keyword">...</span>
    }
}</code></pre>

<blockquote>
  <p>Alamofire 參考資料：<a href="https://github.com/Alamofire/Alamofire">這裡</a></p>
</blockquote>

<hr>



<h4 id="step-2-parse-json"><i class="icon-file"></i>Step 2. - Parse JSON</h4>

<p>首先，建了一個 Class : <strong>Site</strong> 程式碼如下：</p>



<pre class="prettyprint"><code class=" hljs ocaml"><span class="hljs-keyword">class</span> Site: NSObject {
    init(json:JSON){
        <span class="hljs-keyword">let</span> cityName = json[<span class="hljs-string">"C_NAME"</span>].<span class="hljs-built_in">string</span>
        <span class="hljs-keyword">let</span> address = json[<span class="hljs-string">"ADDR"</span>].<span class="hljs-built_in">string</span>
            .
            .
            .
        <span class="hljs-keyword">let</span> xString = json[<span class="hljs-string">"X"</span>].stringValue
        <span class="hljs-keyword">let</span> yString = json[<span class="hljs-string">"Y"</span>].stringValue</code></pre>

<blockquote>
  <p><strong>Note：</strong>從 Data.Taipei 所接收到的 X, Y 為二度分帶座標，需要再轉為經緯度。轉換的過程我參考了 <a href="https://github.com/Hokila/TownCandidateMap/blob/master/TownCandidateMap/TownCandidateMap/GATool.m">GATool</a> 的寫法，並改寫成 Swift 格式。</p>
</blockquote>

<p>當 <strong>ServerManager</strong> 發出 HTTP request 後，將 Server 所回傳的 response.value 轉成 <strong>jsonArray</strong> ，再將 <strong>jsonArray</strong> 內的物件用 <strong>Site</strong> 包起來並 append 進去 <strong>Sites</strong></p>



<pre class="prettyprint"><code class=" hljs cs"><span class="hljs-keyword">var</span> sites = [Site]()

<span class="hljs-keyword">let</span> jsonArray = JSON(<span class="hljs-keyword">value</span>)[<span class="hljs-string">"result"</span>] [<span class="hljs-string">"results"</span>].array
jsonArray.forEach({ (json) <span class="hljs-keyword">in</span>
                    <span class="hljs-keyword">let</span> site = Site(json: json)
                    sites.append(site)
                })</code></pre>

<hr>



<h4 id="step-3-storyboard-mapview-and-detailview"><i class="icon-file"></i> Step 3. - Storyboard : MapView and DetailView</h4>

<p>接收到 Server 所回傳的 response.value 後，便要開始設計該如何呈現畫面。 TaipeiAPI 主要有兩個畫面：</p>

<ul>
<li>以地圖方式呈現施工地點</li>
<li>顯示施工地點的詳細資訊</li>
</ul>

<p>於是，便在Storyboard分別拉了MapViewController與DetailViewController，並在MapViewController前設置了NavigationController。MapViewController 上方的 <strong>Label</strong> 會顯示施工地點的數量，中間的 <strong>MapView</strong> 則會顯示每個施工地點的位置，下方的三個 <strong>Label</strong>分別會顯示「行政區」、「與目前位置的距離」及「預估到達時間」；而 DetailViewController 則會顯示施工地點的詳細資訊</p>

<p><img src="http://imgur.com/My0ShNu.png" alt="" title="storyboard"></p>

<blockquote>
  <p>當然，每個 Component 之間都設定好了 <strong>Autolayout</strong> ，以對應不同尺寸的 iPhone 螢幕，DetailViewController 的地方是將所有Component 用 <strong>StackView</strong> 包起來，以方便統一調整</p>
</blockquote>

<hr>



<h4 id="step-4-delegate-mapviewdelegate"><i class="icon-file"></i>Step 4. - Delegate - MapViewDelegate</h4>

<p>設計完畫面之後，就要開始實作 <strong>MKMapViewDelegate</strong> 下的 Function，由於 APP 一開始就要抓取到使用者的目前為止，因此就需要實作 <strong>didUpdateUserLocation</strong></p>



<pre class="prettyprint"><code class=" hljs r">mapView(mapView: MKMapView, didUpdateUserLocation userLocation: MKUserLocation) {
        <span class="hljs-keyword">...</span>
}
</code></pre>

<p>接下來是要在地圖上將施工地點用 Annotation 的方式呈現，於是先在 <strong>viewForAnnotation</strong> 內定義 Annotation 的樣式</p>



<pre class="prettyprint"><code class=" hljs r">mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -&gt; MKAnnotationView? {
        <span class="hljs-keyword">...</span>
}</code></pre>

<blockquote>
  <p><strong>Note：</strong> AnnotationView 的顯示方式就如同 TableViewCell 一樣加了 <strong>Reuse</strong> 的機制，<strong>Reuse</strong> 機制是為了做到顯示和資料分離，來達到既不影響顯示效果，又能充分節約資源的目的。</p>
</blockquote>

<p>接著再用 <strong>For</strong> 迴圈將所有的施工地點以 Annotation 的方式加到地圖上</p>



<pre class="prettyprint"><code class=" hljs avrasm">        for i <span class="hljs-keyword">in</span> <span class="hljs-number">0.</span>.<span class="hljs-preprocessor">.result</span><span class="hljs-preprocessor">.count</span>-<span class="hljs-number">1</span> {
            let location = CLLocationCoordinate2DMake(lat, long)
            let information = MKPointAnnotation()
            information<span class="hljs-preprocessor">.coordinate</span> = location
            information<span class="hljs-preprocessor">.title</span> = result[i]<span class="hljs-preprocessor">.cityName</span>
            information<span class="hljs-preprocessor">.subtitle</span> = result[i]<span class="hljs-preprocessor">.address</span>

            mapView<span class="hljs-preprocessor">.addAnnotation</span>(information)
        }</code></pre>

<p>而在選取地圖上的任意一個 Annotation 時，APP 就會計算出所選的 Annotation 位置與目前位置之間的距離與預估開車會到達的時間，因此就要在 <strong>didSelectAnnotationView</strong> 實作這個部分</p>



<pre class="prettyprint"><code class=" hljs r">mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
    let request = MKDirectionsRequest()
        .
        .
        .
    let directions = MKDirections(request: request)
        directions.calculateETAWithCompletionHandler { response, error <span class="hljs-keyword">in</span>
            <span class="hljs-keyword">if</span> let error = error {
                    <span class="hljs-keyword">...</span>
            } <span class="hljs-keyword">else</span> {
                    <span class="hljs-keyword">...</span>
            }
        }
    }</code></pre>

<p>最後要實作的部分是 <strong>calloutAccessoryControlTapped</strong> 。在點擊 Annotation 時，會有一個可進入詳細資訊畫面的 Button ，因此在先前所提到的 <strong>viewForAnnotation</strong> 底下新增一個 DetailButton</p>



<pre class="prettyprint"><code class=" hljs fsharp"><span class="hljs-keyword">let</span> detailButton = UIButton(<span class="hljs-class"><span class="hljs-keyword">type</span>: .<span class="hljs-title">DetailDisclosure</span>)</span>
        .
        .
        .
annotationView?.rightCalloutAccessoryView = detailButton</code></pre>

<p>而 DetailButton 的功能則是定義在 <strong>calloutAccessoryControlTapped</strong> ，在這邊決定當 DetailButton 被點擊時，會執行 <strong>performSegueWithIdentifier</strong></p>



<pre class="prettyprint"><code class=" hljs erlang"><span class="hljs-function"><span class="hljs-title">mapView</span><span class="hljs-params">(map<span class="hljs-variable">View</span>: <span class="hljs-variable">MKMapView</span>, annotation<span class="hljs-variable">View</span> view: <span class="hljs-variable">MKAnnotationView</span>, callout<span class="hljs-variable">AccessoryControlTapped</span> control: <span class="hljs-variable">UIControl</span>)</span> {
    <span class="hljs-title">performSegueWithIdentifier</span><span class="hljs-params">(<span class="hljs-string">"SegueIdentifier"</span>, sender: self)</span>
        }</span></code></pre>

<hr>



<h4 id="step-5-segue-prepareforsegue"><i class="icon-file"></i> Step 5.  Segue - PrepareForSegue</h4>

<p>當 DetailButton 被點擊時，會執行 <strong>performSegueWithIdentifier</strong> 進入到詳細資訊的畫面，因此就需要將 Storyboard 上的兩個畫面利用 <strong>Segue</strong> 連結起來並設定好 <strong>Identifier</strong></p>

<p><img src="http://i.imgur.com/s1rMUFS.png" alt="" title="storyboard"></p>

<p>設定好 <strong>Identifier</strong> 之後，需要透過 <strong>prepareForSegue</strong> 來幫忙傳遞詳細資訊畫面上所要呈現的東西</p>



<pre class="prettyprint"><code class=" hljs bash">prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        <span class="hljs-keyword">if</span> segue.identifier == <span class="hljs-string">"showDetail"</span> {
            <span class="hljs-built_in">let</span> destinationVC = segue.destinationViewController 
                    .
                    .
                    .
        }
    }
</code></pre>

<p>如此一來，<strong>TaipeiAPI</strong> 就大功告成了！</p></div></body>
</html>
