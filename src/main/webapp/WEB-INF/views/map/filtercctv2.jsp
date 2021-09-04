<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>    
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
	<title>Insert title here</title>
	
	<script src="https://api2.sktelecom.com/tmap/js?version=1&format=javascript&appKey=e5e6c714-9b68-48fe-9ff8-46d3dcc0e411"></script>
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.3.1/jquery.min.js"></script>
	<script type="text/javascript">									
		var map, marker, markerLayer, vectorLayer;
		
		var count = 0;
		var positions = new Array();			
		
		<c:forEach items="${map2}" var="loc">
			var cctv = new Object();	
			cctv.lon = "${loc.longitude}";
			cctv.lat = "${loc.latitude}";
			positions.push(cctv);
			count = count + 1;
		</c:forEach>
		
		var markerArray = new Array();
		var features = new Array();
		var bounds = new Array();
		
		var style_red = {
				fillColor:"#f2f2f2",
				fillOpacity:0.2,
				strokeColor: "#ff0000",
				strokeWidth: 1,
				strokeDashstyle: "solid",
				pointRadius: 60
			};
		
		function initTmap(){
			
			var coord, circle;
			
			// map 생성
			// Tmap.map을 이용하여, 지도가 들어갈 div, 넓이, 높이를 설정합니다.
			map = new Tmap.Map({div:'map_div', // map을 표시해줄 div
								width:'100%',  // map의 width 설정
								height:'850px' // map의 height 설정
								});
			
			map.setCenter(new Tmap.LonLat("127.04597379499731", "37.65369036685572").transform("EPSG:4326", "EPSG:3857"), 17);
			
			console.log(count); // db에서 불러온 데이터 개수
			
			markerLayer = new Tmap.Layer.Markers(); //마커 레이어 생성
			map.addLayer(markerLayer); //map에 마커 레이어 추가
			
			vectorLayer = new Tmap.Layer.Vector(); // 백터 레이어 생성
			map.addLayers([vectorLayer]); // 지도에 백터 레이어 추가
			
			var size = new Tmap.Size(12, 12); //아이콘 크기 설정
			var offset = new Tmap.Pixel(-(size.w / 2), -(size.h));  //아이콘 중심점 설정
			
			for(var i=0; i<positions.length; i++){
				
				var lonlat = new Tmap.LonLat(positions[i].lon, positions[i].lat).transform("EPSG:4326", "EPSG:3857"); // cctv 좌표 설정
				
				var icon = new Tmap.Icon('http://topopen.tmap.co.kr/imgs/point.png',size, offset); //마커 아이콘 설정
				var label = new Tmap.Label(positions[i].lon + " " + positions[i].lat); // 마커 라벨 설정
								
				marker = new Tmap.Markers(lonlat, icon, label); // 마커 생성
				markerArray.push(marker); // 마커 저장(지우기 위해)
				markerLayer.addMarker(marker); // 마커 레이어에 마커 추가
				
				/* coord = new Tmap.LonLat(positions[i].lon, positions[i].lat).transform("EPSG:4326", "EPSG:3857"); //좌표 설정
				circle = new Tmap.Geometry.Circle(coord.lon, coord.lat, 10); // 원 생성
				
				features[i] = new Tmap.Feature.Vector(circle, null, style_red); // 원 백터 생성
				vectorLayer.addFeatures([features[i]]); // 원 백터 를 백터 레이어에 추가
				
				bounds[i] = features[i].geometry.getBounds(); */
			}
			
			map.events.register("click", map, onClick);
		}	
		
		function filterArea() {
			
			var intercount = 0;
			var removecount = 0;
			
			for(var i=0; i<bounds.length; i++){
				for(var j=i; j<bounds.length; j++){
					if(i!=j){
						if(bounds[i].intersectsBounds(bounds[j]) == true){
							console.log(i + " and " + j);
							intercount = intercount + 1;
							
							markerLayer.removeMarker(markerArray[j]);
							vectorLayer.removeFeatures(features[j]);
							
							removecount = removecount + 1;
						}	
					}
				}
			}
			
			console.log('intersectsBounds : ' + intercount);
			console.log('removeCount : ' + removecount);
		}
		
		function onClick(e) {
			filterArea();			
		}
		
		$(function (){
			initTmap();
		});
	</script>
</head>
<body>
	<div id="map_div"></div>
</body>
</html>