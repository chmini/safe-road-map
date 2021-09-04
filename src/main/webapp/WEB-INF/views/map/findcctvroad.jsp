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
    	var map, markerLayer, size, offset;
    	var count = 0;
		// map 생성
		// Tmap.map을 이용하여, 지도가 들어갈 div, 넓이, 높이를 설정합니다.
		function initTmap() {
			map = new Tmap.Map({
					div : 'map_div', // map을 표시해줄 div
					width : "100%", // map의 width 설정
					height : "850px", // map의 height 설정
				});
			
			map.setCenter(new Tmap.LonLat("126.986072", "37.570028").transform("EPSG:4326", "EPSG:3857"), 15); //설정한 좌표를 "EPSG:3857"로 좌표변환한 좌표값으로 즁심점을 설정합니다.

			markerLayer = new Tmap.Layer.Markers("marker"); //마커 레이어 생성
			map.addLayer(markerLayer); //map에 마커 레이어 추가
			
			map.events.register("click", map, onClick);
		}
		
		var clonlat, s_lon, s_lat, e_lon, e_lat;
		var routeLayer, markerLayer, vector_layer, icon, marker_s, marker_e;
		var distance;
		var markerArray = new Array();
		
		function onClick(e){
			
			console.log(count);
			
			if(count == 0){
				
				// 출발지 마커
				size = new Tmap.Size(24, 38); //아이콘 크기 설정
				offset = new Tmap.Pixel(-(size.w / 2), -size.h);
				
				clonlat = map.getLonLatFromViewPortPx(e.xy).transform("EPSG:3857", "EPSG:4326"); //클릭 부분의 ViewPortPx를 LonLat 좌표로 변환합니다.
				
				s_clon = clonlat.lon;
				s_clat = clonlat.lat;
				
				icon = new Tmap.IconHtml('<img src=http://tmapapis.sktelecom.com/upload/tmap/marker/pin_r_m_s.png />', size, offset); //마커 아이콘 설정
				marker_s = new Tmap.Marker(new Tmap.LonLat(s_clon, s_clat).transform("EPSG:4326", "EPSG:3857"), icon); //설정한 좌표를 "EPSG:3857"로 좌표변환한 좌표값으로 설정합니다.
				markerLayer.addMarker(marker_s); //마커 레이어에 마커 추가
				
			}else if(count == 1){
				
				// 도착지 마커
				clonlat = map.getLonLatFromViewPortPx(e.xy).transform("EPSG:3857", "EPSG:4326"); //클릭 부분의 ViewPortPx를 LonLat 좌표로 변환합니다.
				e_clon = clonlat.lon;
				e_clat = clonlat.lat;
				
				icon = new Tmap.IconHtml('<img src=http://tmapapis.sktelecom.com/upload/tmap/marker/pin_r_m_e.png />', size, offset); //마커 아이콘 설정
				marker_e = new Tmap.Marker(new Tmap.LonLat(e_clon, e_clat).transform("EPSG:4326", "EPSG:3857"), icon); //설정한 좌표를 "EPSG:3857"로 좌표변환한 좌표값으로 설정합니다.
				markerLayer.addMarker(marker_e); //마커 레이어에 마커 추가
				
				
				// 길찾기
				var headers = {}; 
				headers["appKey"]="e5e6c714-9b68-48fe-9ff8-46d3dcc0e411"; //실행을 위한 키 입니다. 발급받으신 AppKey(서버키)를 입력하세요.
				
				var node;
				var pointobj = new Object();
				var pointnode = new Array();
				var tmpPoint = new Array();
				var tmp, len;
				
				$.ajax({
					method:"POST",
					headers : headers,
					url: "https://api2.sktelecom.com/tmap/routes/pedestrian?version=1&format=xml", //보행자 경로안내 api 요청 url입니다.
					async:false,
					data:{
						//출발지 위경도 좌표입니다.
						startX : s_clon,
						startY : s_clat,
						//목적지 위경도 좌표입니다.
						endX : e_clon,
						endY : e_clat,
						//경유지의 좌표입니다.
						//passList : "126.987319,37.565778_126.983072,37.573028",
						//출발지, 경유지, 목적지 좌표계 유형을 지정합니다.
						reqCoordType : "WGS84GEO",
						resCoordType : "EPSG3857",
						//각도입니다.
						angle : "172",
						//출발지 명칭입니다.
						startName : "출발지",
						//목적지 명칭입니다.
						endName : "도착지",
						searchOption: 4
					},
					//데이터 로드가 성공적으로 완료되었을 때 발생하는 함수입니다.
					success:function(response){
						prtcl = response;
						
						// 결과 출력
						var innerHtml = "";
						var prtclString = new XMLSerializer().serializeToString(prtcl); //xml to String
						//console.log(prtclString);
					    xmlDoc = $.parseXML( prtclString ),
					    $xml = $( xmlDoc ),
				    	$intRate = $xml.find("Document");					    
				    	
				    	var tDistance = "총 거리 : "+($intRate[0].getElementsByTagName("tmap:totalDistance")[0].childNodes[0].nodeValue/1000).toFixed(1)+"km,";
				    	var tTime = " 총 시간 : "+($intRate[0].getElementsByTagName("tmap:totalTime")[0].childNodes[0].nodeValue/60).toFixed(0)+"분";
				    	
				    	$place = $xml.find("Placemark");				    	
				    	len = $place.length;				    	
				    	tmpPoint.push($place);				    	
				    	
				    	//console.log($place[0].getElementsByTagName("Point")[0].getElementsByTagName("coordinates")[0].childNodes[0].nodeValue);				    	
				    	
				    	for(var i=0; i<len; i++){
				    		pointnode[i] = tmpPoint[0][i].lastElementChild.childNodes[1].childNodes[0].nodeValue;
				    	}
				    	
				    	//tmp = pointnode[0];
				    	
				    	//node = $intRate[0].getElementsByTagName("Placemark")[0];
				
				    	$("#result").text(tDistance+tTime);
						
						prtcl = new Tmap.Format.KML({extractStyles:true, extractAttributes:true}).read(prtcl); //데이터(prtcl)를 읽고, 벡터 도형(feature) 목록을 리턴합니다.
						routeLayer = new Tmap.Layer.Vector("route"); // 백터 레이어 생성
						//표준 데이터 포맷인 KML을 Read/Write 하는 클래스 입니다.
						//벡터 도형(Feature)이 추가되기 직전에 이벤트가 발생합니다.
						routeLayer.events.register("beforefeatureadded", routeLayer, onBeforeFeatureAdded);
						        function onBeforeFeatureAdded(e) {
							        	var style = {};
							        	switch (e.feature.attributes.styleUrl) {
							        	case "#pointStyle":
								        	style.externalGraphic = "http://topopen.tmap.co.kr/imgs/point.png"; //렌더링 포인트에 사용될 외부 이미지 파일의 url입니다.
								        	style.graphicHeight = 16; //외부 이미지 파일의 크기 설정을 위한 픽셀 높이입니다.
								        	style.graphicOpacity = 1; //외부 이미지 파일의 투명도 (0-1)입니다.
								        	style.graphicWidth = 16; //외부 이미지 파일의 크기 설정을 위한 픽셀 폭입니다.
							        	break;
							        	default:
								        	style.strokeColor = "#009933"; //stroke에 적용될 16진수 color
								        	style.strokeOpacity = "1"; //stroke의 투명도(0~1)
								        	style.strokeWidth = "5"; //stroke의 넓이(pixel 단위)
							        	};
						        	e.feature.style = style;
						        }
						
						routeLayer.addFeatures(prtcl); //레이어에 도형을 등록합니다.
						map.addLayer(routeLayer); //맵에 레이어 추가
					},
					//요청 실패시 콘솔창에서 에러 내용을 확인할 수 있습니다.
					error:function(request,status,error){
						console.log("code:"+request.status+"\n"+"message:"+request.responseText+"\n"+"error:"+error);
					}
				});
				
				//console.log(len);
				//console.log(pointnode);
				console.log(tmpPoint);
				console.log(pointnode);
				
				for(var i=0; i<len; i++){
					pointnode[i] = pointnode[i].split(" ");
					for(var j=0; j<pointnode[i].length; j++){
						if(pointnode[i][j] == ""){
							pointnode[i].splice(j,1);
						}else if(j > 1){
							pointnode[i].splice(0,1);
							pointnode[i].splice(pointnode[i].length-1, 1);
						}
					}
				}
				
				console.log(pointnode);				
				
				$.ajax({
					method:"GET",
					url:"https://api2.sktelecom.com/tmap/routes/distance?version=1&format=xml",//직선거리 계산 api 요청 url입니다.
					async:false, 
					data:{
						//시작 지점 위경도 좌표입니다.
						"startX" : s_clon,
						"startY" : s_clat,
						//끝 지점 위경도 좌표입니다. 
						"endX" : e_clon,
						"endY" : e_clat,
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
				
				
				// 원
				vector_layer = new Tmap.Layer.Vector('Tmap Vector Layer'); // 백터 레이어 생성
				map.addLayers([vector_layer]); // 지도에 백터 레이어 추가

				//console.log((s_clon+e_clon)/2, (s_clat+e_clat)/2);
				
				var coord = new Tmap.LonLat((s_clon+e_clon)/2, (s_clat+e_clat)/2).transform("EPSG:4326", "EPSG:3857");
				var circle = new Tmap.Geometry.Circle(coord.lon, coord.lat, distance/2, {unit:"m"}); // 원 생성
				
				//지도상에 그려질 스타일을 설정합니다
				var style_red = {
					fillColor: "#ffffff",
					fillOpacity: 0,
					strokeColor: "#FF0000",
					strokeWidth: 3,
					strokeDashstyle: "solid",
					pointRadius: 60
				};
				
				var circleFeature = new Tmap.Feature.Vector(circle, null, style_red); //원 백터 생성
				vector_layer.addFeatures([circleFeature]); //원 백터 를 백터 레이어에 추가
												
				//map.zoomToExtent(vector_layer.getDataExtent()); //map의 zoom을 routeLayer의 영역에 맞게 변경합니다.
				
				
				// cctv 표시
				size = new Tmap.Size(12, 19); 
				offset = new Tmap.Pixel(-(size.w / 2), -(size.h));
				
				var positions = new Array();			
				
				<c:forEach items="${map}" var="loc">
					var cctv = new Object();	
					cctv.lon = "${loc.longitude}";
					cctv.lat = "${loc.latitude}";
					positions.push(cctv);				
				</c:forEach>

				var cctvlonlat = new Array();
				var cctvmarklonlat = new Array();
				
				for(var i=0; i<positions.length; i++){
					cctvlonlat[i] = new Tmap.LonLat(positions[i].lon, positions[i].lat);
					cctvmarklonlat [i] = new Tmap.LonLat(positions[i].lon, positions[i].lat).transform("EPSG:4326", "EPSG:3857");
				}			
				
				var marklonlat = new Array();
				var comparelonlat = new Array();
				
				for(var i=0; i<circleFeature.geometry.getVertices().length; i++){
					comparelonlat[i] = new Tmap.LonLat(circleFeature.geometry.getVertices()[i].x, circleFeature.geometry.getVertices()[i].y).transform("EPSG:3857", "EPSG:4326");
					marklonlat[i] = new Tmap.LonLat(circleFeature.geometry.getVertices()[i].x, circleFeature.geometry.getVertices()[i].y);				
				}
				
				/*
				for(var j=0; j<comparelonlat.length; j++){
					var icon = new Tmap.Icon('http://tmapapis.sktelecom.com/upload/tmap/marker/pin_b_m_a.png',size, offset);
					marker = new Tmap.Marker(marklonlat[j], icon);
					markerArray.push(marker);
					markerLayer.addMarker(marker); 
				}
				*/
				
				for(var i=0; i<cctvlonlat.length; i++){
					for(var j=0; j<comparelonlat.length; j++){
						if(comparelonlat[j].lon < clonlat.lon && comparelonlat[j].lat < clonlat.lat){
							if(cctvlonlat[i].lon >= comparelonlat[j].lon && cctvlonlat[i].lat >= comparelonlat[j].lat && clonlat.lon >= cctvlonlat[i].lon && clonlat.lat >= cctvlonlat[i].lat){
								icon = new Tmap.Icon('http://tmapapis.sktelecom.com/upload/tmap/marker/pin_b_m_a.png',size, offset);
								marker = new Tmap.Marker(cctvmarklonlat[i], icon);
								markerArray.push(marker);
								markerLayer.addMarker(marker);
								//console.log(cctvlonlat[i]);
							}
						}else if(comparelonlat[j].lon > clonlat.lon && comparelonlat[j].lat < clonlat.lat){
							if(cctvlonlat[i].lon <= comparelonlat[j].lon && cctvlonlat[i].lat >= comparelonlat[j].lat && clonlat.lon <= cctvlonlat[i].lon && clonlat.lat >= cctvlonlat[i].lat){
								icon = new Tmap.Icon('http://tmapapis.sktelecom.com/upload/tmap/marker/pin_b_m_a.png',size, offset);
								marker = new Tmap.Marker(cctvmarklonlat[i], icon);
								markerArray.push(marker);
								markerLayer.addMarker(marker); 
								//console.log(cctvlonlat[i]);
							}
						}else if(comparelonlat[j].lon < clonlat.lon && comparelonlat[j].lat > clonlat.lat){
							if(cctvlonlat[i].lon >= comparelonlat[j].lon && cctvlonlat[i].lat <= comparelonlat[j].lat && clonlat.lon >= cctvlonlat[i].lon && clonlat.lat <= cctvlonlat[i].lat){
								icon = new Tmap.Icon('http://tmapapis.sktelecom.com/upload/tmap/marker/pin_b_m_a.png',size, offset);
								marker = new Tmap.Marker(cctvmarklonlat[i], icon);
								markerArray.push(marker);
								markerLayer.addMarker(marker);
								//console.log(cctvlonlat[i]);
							}
						}else if(comparelonlat[j].lon > clonlat.lon && comparelonlat[j].lat > clonlat.lat){
							if(cctvlonlat[i].lon <= comparelonlat[j].lon && cctvlonlat[i].lat <= comparelonlat[j].lat && clonlat.lon <= cctvlonlat[i].lon && clonlat.lat <= cctvlonlat[i].lat){
								icon = new Tmap.Icon('http://tmapapis.sktelecom.com/upload/tmap/marker/pin_b_m_a.png',size, offset);
								marker = new Tmap.Marker(cctvmarklonlat[i], icon);
								markerArray.push(marker);
								markerLayer.addMarker(marker); 
								//console.log(cctvlonlat[i]);
							}
						}else{
							console.log(cctvlonlat[i]);
						}	
					}	
				}
				
				var eqcount = new Array();
				
				for(var i=1; i<markerArray.length; i++){
					if(markerArray[i].lonlat.lon == markerArray[i-1].lonlat.lon && markerArray[i].lonlat.lat == markerArray[i-1].lonlat.lat){
						eqcount[i-1] = i-1;
					}else{
						eqcount[i-1] = -1;
					}
					//console.log(eqcount[i-1]);
				}
				
				for(var i=0; i<eqcount.length; i++){
					if(eqcount[i] == -1){
						continue;
					}else{
						markerArray.splice(i,1,0);
					}
				}
				
				var newlonlat = new Array();
				var cc = -1;
				
				for(var i in markerArray){
					if(markerArray[i] == 0){
						continue;
					}else{
						cc = cc + 1;
						newlonlat[cc] = new Tmap.LonLat(markerArray[i].lonlat.lon, markerArray[i].lonlat.lat).transform("EPSG:3857", "EPSG:4326");
					}
				}
				
				console.log(cc);
				
				var strcctv = "";
				
				for(var i=0; i<cc; i++){
					strcctv += newlonlat[i].lon+","+newlonlat[i].lat+"_";
					if(i == cc-1){
						strcctv += newlonlat[i].lon+","+newlonlat[i].lat;
					}
				}
				
				console.log(strcctv);
				
				
				
			}else if(count == 2){
				
				markerLayer.destroy();
				routeLayer.destroy();
				vector_layer.destroy();
				
				markerLayer = new Tmap.Layer.Markers("marker"); //마커 레이어 생성
				map.addLayer(markerLayer); //map에 마커 레이어 추가
				
				markerArray = new Array();
				
				count = -1;
			}
			
			count = count + 1;
			
			
		}
		
		$(function() {
			initTmap();
		});
		 
    </script>
</head>
<body>
	<div id="map_div">
	</div>
	<p id="result"></p>
	<p id="result2"></p>
</body>
</html>