# Note: You MUST have curl 7.47+ with http/2 support compiled in

curl -v \
-d '{
    "action" : "5010",
     "data" : "{\"appKey\":\"ZscjyPDUIaEKDGBKw55ULB9goWEKSJPjCNNC\"}",
    "title" : "我的来电",
}' \
-H "apns-topic: com.pajk.jppersonaldoc.voip" \
-H "apns-priority: 10" \
-H "apns-push-type: voip" \
--http2 \
--cert-type P12 --cert voipcert.p12:Htkk8080 \
https://api.development.push.apple.com/3/device/1f4f8b689759fa8e1fcd47584e80634c0be0ebd6ba82b48d8eebde041a4d7fe3
