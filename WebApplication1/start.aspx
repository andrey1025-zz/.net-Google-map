<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="start.aspx.cs" CodeFile="start.aspx.cs" Inherits="WebApplication1.start" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Google Map</title>
    <style>
        html, body, .main-wrapper, .search-wrapper, .map-wrapper {
            height: 100%;
        }
        .search-wrapper{
            width:20%;
            background:#2bb7a4;
            padding:10px 20px;
        }
        .map-wrapper{
            width:80%;
        }
        .search-wrapper, .map-wrapper{
            float:left;
        }
        .form-group{
            width:100%;
        }
        .reset-btn{
            margin-left:10px;
        }
        .search-btn, .reset-btn{
            float:right;
        }
        .detail > label{
            color: #e6e6e6;
            font-weight: 600;
        }
        .detail > div > label {
            color: #c4e4e0;
            font-weight: 600;
        }
        .loader,
        .loader:before,
        .loader:after {
          background: #5b5b5b;
          -webkit-animation: load1 1s infinite ease-in-out;
          animation: load1 1s infinite ease-in-out;
          width: 1em;
          height: 4em;
        }
        .loader {
          color: #5b5b5b;
          text-indent: -9999em;
          margin: 88px auto;
          top: calc(50% - 88px);
          position: relative;
          font-size: 11px;
          -webkit-transform: translateZ(0);
          -ms-transform: translateZ(0);
          transform: translateZ(0);
          -webkit-animation-delay: -0.16s;
          animation-delay: -0.16s;
        }
        .loader:before,
        .loader:after {
          position: absolute;
          top: 0;
          content: '';
        }
        .loader:before {
          left: -1.5em;
          -webkit-animation-delay: -0.32s;
          animation-delay: -0.32s;
        }
        .loader:after {
          left: 1.5em;
        }
        @-webkit-keyframes load1 {
          0%,
          80%,
          100% {
            box-shadow: 0 0;
            height: 4em;
          }
          40% {
            box-shadow: 0 -2em;
            height: 5em;
          }
        }
        @keyframes load1 {
          0%,
          80%,
          100% {
            box-shadow: 0 0;
            height: 4em;
          }
          40% {
            box-shadow: 0 -2em;
            height: 5em;
          }
        }

    </style>
    <link href="css/bootstrap/css/bootstrap.min.css" rel="stylesheet"/>
    <link href="css/typeahead.css" rel="stylesheet"/>

</head>
<body>
    <div class="main-wrapper">
        <div class="search-wrapper">
            <div class="form-group text-center">
                <img src="map_logo.png" style="height:100px;"/>
            </div>
            <div class="form-group">
                 <input class="form-control address-typeahead""/>
            </div>
            <div class="form-group btn-group">
                <button class="form-control search-btn btn-success" onclick="search();">Search</button>
                <button class="form-control reset-btn btn-danger" onclick="reset();">Reset</button>
            </div>
            <div class="form-group detail">
                <label>ADDRESS</label>
                <div class="address">
                    <label></label>
                </div>
            </div>
            <div class="form-group detail">
                <label>BUILDING NAME</label>
                <div class="building">
                    <label></label>
                </div>
            </div>
            <div class="form-group detail">
                <label>CITY</label>
                <div class="city">
                    <label></label>
                </div>
            </div>
            <div class="form-group detail">
                <label>PROVINCE</label>
                <div class="province">
                    <label></label>
                </div>
            </div>
            <div class="form-group detail">
                <label>COUNTRY</label>
                <div class="country">
                    <label></label>
                </div>
            </div>
            <div class="form-group detail">
                <label>POSTAL CODE</label>
                <div class="postalcode">
                    <label></label>
                </div>
            </div>
            <div class="form-group detail">
                <label>NUMBER OF FLOORS</label>
                <div class="numberoffloors">
                    <label></label>
                </div>
            </div>
        </div>
        <div class="map-wrapper" id="map">
            <div class="loader">Loading...</div>
        </div>
    </div>
</body>
<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.5.1/jquery.min.js"></script>
<script src="js/typeahead.js"></script>

<script src="css/bootstrap/js/bootstrap.min.js"></script>
<script type='text/javascript' src="https://cdn.rawgit.com/abdmob/x2js/master/xml2json.js"></script>
<script src="https://maps.googleapis.com/maps/api/js?key=AIzaSyDESb1qOhUPpsQ3LXigAbCCs2ESLX-0WNQ&libraries=places&v=weekly" defer></script>
<script>
    $(function () {
        //drawPlacesOnMap("43.6534", "-79.3841", "");
        //drawPlacesOnMapByAddress("100 Queen St W, Toronto, ON M5H 2N2");
        drawPlacesOnMapByAddress("toronto", "43.6534", "-79.3841", "");
    });

    var map;
    var geocoder;
    var address_arr = new Array();
    var latlng;
    var infowindow;
    var arrAddressName = [];
    var zoom = 13;
    function drawPlacesOnMapByAddress(address, lat, lng, center_name) {
        $.ajax({
            url: "start.aspx/getPlacesFromAPIByAddress",
            method: "post",
            data: JSON.stringify({
                address: address
            }),
            contentType: "application/json;charset=utf-8",
            dataType: "json",
            success: function (res) {
                var xmlData = $.parseXML(res.d);
                var x2js = new X2JS();
                var jsonObj = x2js.xml2json(xmlData); // Convert XML to JSON

                address_arr = jsonObj.Envelope.Body.get_list_of_points_by_addressResponse.get_list_of_points_by_addressResult.diffgram.DocumentElement.pointsdata;
                for (var i = 0; i < address_arr.length; i++) {
                    arrAddressName.push(address_arr[i].address);
                }

                initAutocomplete(address_arr, lat, lng, center_name);

            },
            error: function (err) {

            }
        })
    }
    function drawPlacesOnMap(lat, lng, center_name) {
        $.ajax({
            url: "start.aspx/getPlacesFromAPI",
            method: "post",
            data: JSON.stringify({
                lat: lat,
                lng: lng,
            }),
            contentType:"application/json;charset=utf-8",
            dataType: "json",
            success: function (res) {
                var xmlData = $.parseXML(res.d);
                var x2js = new X2JS();
                var jsonObj = x2js.xml2json(xmlData); // Convert XML to JSON
                address_arr = jsonObj.Envelope.Body.get_list_of_points_by_coordinatesResponse.get_list_of_points_by_coordinatesResult.diffgram.DocumentElement.pointsdata;
                //for (var i = 0; i < address_arr.length; i++) {
                //    arrAddressName.push(address_arr[i].address);
                //}

                initAutocomplete(address_arr, lat, lng, center_name);
            },
            error: function (err) {

            }
        })
    }
    var substringMatcher = function (strs) {
        return function findMatches(q, cb) {
            var matches, substrRegex;

            // an array that will be populated with substring matches
            matches = [];

            // regex used to determine if a string contains the substring `q`
            substrRegex = new RegExp(q, 'i');
            // iterate through the pool of strings and for any string that
            // contains the substring `q`, add it to the `matches` array
            $.each(strs, function (i, str) {
                if (substrRegex.test(str)) {
                    matches.push(str);
                }
            });
            var uniqueChars = matches.filter((c, index) => {
                return matches.indexOf(c) === index;
            });
            cb(uniqueChars);

        };
    };
    $('.address-typeahead').typeahead({
        hint: true,
        highlight: true,
        minLength: 1,
        cache:false,
        limit : 10
    },
    {
        source: substringMatcher(arrAddressName)
        });

    $('.address-typeahead').keyup(function (e) {
        if (e.keyCode == 13) {
            var address = $(this).val();
            showDetail(address);
        }
    });

    function search() {
        var address = $(".address-typeahead.tt-input").val();
        showDetail(address);
    }

    function reset() {
        var address = $(".address-typeahead.tt-input").val();
        if (address != "") {
            var buildingID = getBuildingID(address);
            $.ajax({
                url: "start.aspx/rebootDevice",
                method: "post",
                data: JSON.stringify({
                    buildingID: buildingID,
                }),
                contentType: "application/json;charset=utf-8",
                dataType: "json",
                success: function (res) {
                    var xmlData = $.parseXML(res.d);
                    var x2js = new X2JS();
                    var jsonObj = x2js.xml2json(xmlData); // Convert XML to JSON
                    var result = jsonObj.Envelope.Body.reboot_deviceResponse.reboot_deviceResult;
                    if (result == "true") {
                        alert(result);
                        alert("Reboot device operation is successfully done.");
                    } else {
                        alert("Failed");
                    }

                },
                error: function (err) {
                    alert("Something wrong");
                }
            });
        } else {
            alert("No selected value");
        }
    }

    function getBuildingID(address) {
        var buildingID = "";
        for (var i = 0; i < address_arr.length; i++) {
            if (address == address_arr[i].address) {
                buildingID = address_arr[i].iid;
                break;
            }
        }
        return buildingID;
    }

    function showDetail(address) {
        for (var i = 0; i < address_arr.length; i++) {
            if (address == address_arr[i].address) {
                $('div.address label').html(address_arr[i].address);
                $('div.building label').html(address_arr[i].name);
                $("input.address-typeahead.tt-input").val(address_arr[i].address);
                $('div.city label').html(address_arr[i].City);
                $('div.province label').html(address_arr[i].Province);
                $('div.country label').html(address_arr[i].Country);
                $('div.postalcode label').html(address_arr[i].Postalcode);
                $('div.numberoffloors label').html(address_arr[i].floor);
                var latitude = parseFloat(address_arr[i].latitude) - 0.00005;
                var longitude = parseFloat(address_arr[i].longitude)
                var selectedlatlng = new google.maps.LatLng(latitude, longitude);
                var pt = new google.maps.LatLng(latitude, longitude);
                map.addListener("zoom_changed", function () {
                    zoom = map.getZoom();
                });
                map.setCenter(pt);
                zoom = 17;
                map.setZoom(zoom);
                var marker = new google.maps.Marker({
                    position: selectedlatlng,
                    map: map,
                    draggable: true,
                    id: address_arr[i].iid,
                    html: address_arr[i].name + "<br>" + address_arr[i].address + "<br>" + address_arr[i].City + "<br>" + address_arr[i].Province + "<br>" + address_arr[i].Country + ", " + address_arr[i].Postalcode + ", " + address_arr[i].floor,
                });
                marker.setIcon({
                    url: "http://maps.google.com/mapfiles/ms/icons/red-dot.png",
                    scaledSize: new google.maps.Size(40, 40)
                });

                google.maps.event.addListener(marker, 'mouseover', function (event) {
                    infowindow.setContent(this.html);
                    for (var i = 0; i < address_arr.length; i++) {
                        if (this.id == address_arr[i].iid) {
                            $('div.address label').html(address_arr[i].address);
                            $("input.address-typeahead.tt-input").val(address_arr[i].address);
                            $('div.building label').html(address_arr[i].name);
                            $('div.city label').html(address_arr[i].City);
                            $('div.province label').html(address_arr[i].Province);
                            $('div.country label').html(address_arr[i].Country);
                            $('div.postalcode label').html(address_arr[i].Postalcode);
                            $('div.numberoffloors label').html(address_arr[i].floor);
                            break;
                        }
                    }
                    infowindow.setPosition(event.latLng);
                    infowindow.open(map, this);
                });
                google.maps.event.addListener(marker, 'mouseout', function (event) {
                    infowindow.close();
                });
            }
        }
    }

    function initAutocomplete(address_arr, lat, lng, center_name) {
        console.log(address_arr);
        map = new google.maps.Map(document.getElementById("map"), {
            center: {
                lat: parseFloat(lat),
                lng: parseFloat(lng)
            },
            zoom: zoom,
            mapTypeId: "roadmap"
        }); // Create the search box and link it to the UI element.
        map.addListener("zoom_changed", function () {
            zoom = map.getZoom();
        });
        google.maps.event.addListener(map, 'dragend', function () {
            var latitude = this.getCenter().lat().toString();
            var longitude = this.getCenter().lng().toString();
            drawPlacesOnMap(latitude, longitude, center_name);
        });
        for (var i = 0; i < address_arr.length; i++) {
            setMarker(address_arr[i], center_name);
        }
    }

    function setMarker(info, center_name) {
        var marker;
        geocoder = new google.maps.Geocoder();
        infowindow = new google.maps.InfoWindow();
        var lat = parseFloat(info.latitude);
        var lng = parseFloat(info.longitude);
        latlng = new google.maps.LatLng(lat, lng);
        if (info.name == center_name) {
            marker = new google.maps.Marker({
                position: latlng,
                map: map,
                draggable: false,               // cant drag it
                id: info.iid,
                html: info.name + "<br>" + info.address + "<br>" + info.City + "<br>" + info.Province + "<br>" + info.Country + ", " + info.Postalcode + ", " + info.floor,    // Content display on marker click
                icon: {
                    url: "http://maps.google.com/mapfiles/ms/icons/red-dot.png",
                    scaledSize: new google.maps.Size(35, 35)
                }
            });
        } else {
            marker = new google.maps.Marker({
                position: latlng,
                map: map,
                draggable: false,               // cant drag it
                id: info.iid,
                html: info.name + "<br>" + info.address + "<br>" + info.City + "<br>" + info.Province + "<br>" + info.Country + ", " + info.Postalcode + ", " + info.floor,    // Content display on marker click
                icon: "http://maps.google.com/mapfiles/ms/icons/green-dot.png"       // Give ur own image
            });
        }
        google.maps.event.addListener(marker, 'mouseover', function (event) {
            infowindow.setContent(this.html);
            infowindow.setPosition(event.latLng);
            infowindow.open(map, this);
        });

        google.maps.event.addListener(marker, 'mouseout', function (event) {
            infowindow.close();
        });

        google.maps.event.addListener(marker, 'click', function (event) {
            for (var i = 0; i < address_arr.length; i++) {
                if (this.id == address_arr[i].iid) {
                    $('div.address label').html(address_arr[i].address);
                    $('div.building label').html(address_arr[i].name);
                    $("input.address-typeahead.tt-input").val(address_arr[i].address);
                    $('div.city label').html(address_arr[i].City);
                    $('div.province label').html(address_arr[i].Province);
                    $('div.country label').html(address_arr[i].Country);
                    $('div.postalcode label').html(address_arr[i].Postalcode);
                    $('div.numberoffloors label').html(address_arr[i].floor);
                    drawPlacesOnMap(address_arr[i].latitude, address_arr[i].longitude, address_arr[i].name);
                    break;
                }
            }
        });
    }

</script>
</html>
