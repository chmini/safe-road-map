<!DOCTYPE html>
<html>
<head>
	<script src="https://api2.sktelecom.com/tmap/js?version=1&format=javascript&appKey=e5e6c714-9b68-48fe-9ff8-46d3dcc0e411"></script>
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.3.1/jquery.min.js"></script>
	<script type="text/javascript">
				
		var map, marker, markerLayer;
		var circle, circleFeature, vectorLayer;
		
		var start, end, Center; // 출발지, 목적지, 중심좌표
		var distance;	// 반지름
		
		var px1, px2;
		
		var style_green = {
				fillColor:"#f2f2f2",
				fillOpacity:0.2,
				strokeColor: "#009933",
				strokeWidth: 1,
				strokeDashstyle: "solid",
				pointRadius: 60
			};
		
		var data = new Array(Array(), Array());
			
		function initTmap(){
			
			map = new Tmap.Map({div:'map_div', // map을 표시해줄 div
								width:'100%',  // map의 width 설정
								height:'850px' // map의 height 설정
								}); 
			
			map.setCenter(new Tmap.LonLat("127.04090314262496", "37.65350370915024").transform("EPSG:4326", "EPSG:3857"), 16);
			
			markerLayer = new Tmap.Layer.Markers(); //마커 레이어 생성
			map.addLayer(markerLayer); //map에 마커 레이어 추가
			
			vectorLayer = new Tmap.Layer.Vector(); // 백터 레이어 생성
			map.addLayers([vectorLayer]); // 지도에 백터 레이어 추가
			
			map.events.register("click", map, onClick);
		}
		
		var count = 0;
		var markerArray = new Array();
		
		function onClick(e) {
			
			console.log('count : ' + count);
			
			if(count == 0){
				
				var size = new Tmap.Size(18, 29); //아이콘 크기 설정
				var offset = new Tmap.Pixel(-(size.w / 2), -(size.h));  //아이콘 중심점 설정
				
				var clonlat = map.getLonLatFromViewPortPx(e.xy);
				start = new Tmap.LonLat(clonlat.lon, clonlat.lat).transform("EPSG:3857", "EPSG:4326");
				
				px1 = map.getPixelFromLonLat(new Tmap.LonLat(clonlat.lon, clonlat.lat));
				
				console.log(px1);
				
				data[0][0] = [start.lat];
				data[0][1] = [start.lon];
				
				//console.log(data[0]);
					
				var icon = new Tmap.Icon('http://tmapapis.sktelecom.com/upload/tmap/marker/pin_r_m_s.png',size, offset); //마커 아이콘 설정
				
				marker = new Tmap.Markers(clonlat, icon); // 마커 생성
				markerArray.push(marker); // 마커 저장(지우기 위해)
				markerLayer.addMarker(marker); // 마커 레이어에 마커 추가
						
			}else if(count == 1){
				
				var size = new Tmap.Size(18, 29); //아이콘 크기 설정
				var offset = new Tmap.Pixel(-(size.w / 2), -(size.h));  //아이콘 중심점 설정
				
				var clonlat = map.getLonLatFromViewPortPx(e.xy);	
				end = new Tmap.LonLat(clonlat.lon, clonlat.lat).transform("EPSG:3857", "EPSG:4326");
				
				px2 = map.getPixelFromLonLat(new Tmap.LonLat(clonlat.lon, clonlat.lat));
				
				console.log(px2);
				
				data[1][0] = [end.lat];
				data[1][1] = [end.lon];
				
				//console.log(data[1]);
				
				var icon = new Tmap.Icon('http://tmapapis.sktelecom.com/upload/tmap/marker/pin_r_m_e.png',size, offset); //마커 아이콘 설정
				
				marker = new Tmap.Markers(clonlat, icon); // 마커 생성
				markerArray.push(marker); // 마커 저장(지우기 위해)
				markerLayer.addMarker(marker); // 마커 레이어에 마커 추가
				
				console.log(GetCenterFromDegrees(data));
				
				Center = new Tmap.LonLat(GetCenterFromDegrees(data)[1], GetCenterFromDegrees(data)[0]);
				var drawforCenter = new Tmap.LonLat(GetCenterFromDegrees(data)[1], GetCenterFromDegrees(data)[0]).transform("EPSG:4326", "EPSG:3857");
				
				var icon = new Tmap.Icon('http://tmapapis.sktelecom.com/upload/tmap/marker/pin_r_m_a.png',size, offset); //마커 아이콘 설정
				
				marker = new Tmap.Markers(drawforCenter, icon); // 마커 생성
				markerArray.push(marker); // 마커 저장(지우기 위해)
				markerLayer.addMarker(marker); // 마커 레이어에 마커 추가
				
				$.ajax({
					method:"GET",
					url:"https://api2.sktelecom.com/tmap/routes/distance?version=1&format=xml",//직선거리 계산 api 요청 url입니다.
					async:false, 
					data:{
						//시작 지점 위경도 좌표입니다.
						"startX" : start.lon,
						"startY" : start.lat,
						//끝 지점 위경도 좌표입니다. 
						"endX" : end.lon,
						"endY" : end.lat,
						//입력하는 좌표계 유형을 지정합니다.
						"reqCoordType" : "WGS84GEO",
						//실행을 위한 키 입니다. 발급받으신 AppKey(서버키)를 입력하세요.
						"appKey" : "e5e6c714-9b68-48fe-9ff8-46d3dcc0e411"
					},
					//데이터 로드가 성공적으로 완료되었을 때 발생하는 함수입니다.
					success:function(response){
						prtcl = response;
						
						var prtclString = new XMLSerializer().serializeToString(prtcl);//xml to String	
					    xmlDoc = $.parseXML( prtclString ),
					    $xml = $( xmlDoc ),
					    $intRate = $xml.find("distanceInfo");
						distance = $intRate[0].getElementsByTagName("distance")[0].childNodes[0].nodeValue;
						
						$("#result2").text("두점의 직선거리 : "+distance+"m");
					},
					//요청 실패시 콘솔창에서 에러 내용을 확인할 수 있습니다.
					error:function(request,status,error){
						console.log("code:"+request.status+"\n"+"message:"+request.responseText+"\n"+"error:"+error);
					}
				});
				
				var pxdis = Math.sqrt(Math.pow(Math.abs(px1.x - px2.x), 2)+Math.pow(Math.abs(px1.y - px2.y), 2));
				
				console.log(pxdis);
				
				circle = new Tmap.Geometry.Circle(drawforCenter.lon, drawforCenter.lat, distance/2, {unit:"m"}); // 원 생성
				
				circleFeature = new Tmap.Feature.Vector(circle, null, style_green); // 원 백터 생성
				vectorLayer.addFeatures(circleFeature); // 원 백터 를 백터 레이어에 추가
				
			}else if(count == 2){
				
				for(var i=0; i<markerArray.length; i++){
					markerLayer.removeMarker(markerArray[i]);	
				}
				
				vectorLayer.removeFeatures(circleFeature);
				
				count = -1;
			}
					
			count = count + 1;
			
		}
		
		/*
		var data = [
			[37.65535521290941, 127.0395472221932],
			[37.654590747417686, 127.04637076193177]
		];
		*/
		
		function GetCenterFromDegrees(data)
		{       
		    if (!(data.length > 0)){
		        return false;
		    } 
	
		    var num_coords = data.length;
	
		    var X = 0.0;
		    var Y = 0.0;
		    var Z = 0.0;
	
		    for(i = 0; i < data.length; i++){
		        var lat = data[i][0] * Math.PI / 180;
		        var lon = data[i][1] * Math.PI / 180;
	
		        var a = Math.cos(lat) * Math.cos(lon);
		        var b = Math.cos(lat) * Math.sin(lon);
		        var c = Math.sin(lat);
	
		        X += a;
		        Y += b;
		        Z += c;
		    }
	
		    X /= num_coords;
		    Y /= num_coords;
		    Z /= num_coords;
	
		    var lon = Math.atan2(Y, X);
		    var hyp = Math.sqrt(X * X + Y * Y);
		    var lat = Math.atan2(Z, hyp);
	
		    var newX = (lat * 180 / Math.PI);
		    var newY = (lon * 180 / Math.PI);
	
		    return new Array(newX, newY);
		}
		
		$(function() {
			initTmap();
		});
		
	</script>
</head>
<body>
	<div id="map_div"></div>
	<p id="result2"></p>
</body>
</html>