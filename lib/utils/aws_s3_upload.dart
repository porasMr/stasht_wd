// import 'dart:convert';
// import 'dart:io';
// import 'package:aws_s3_upload/aws_s3_upload.dart';
// import 'package:crypto/crypto.dart';
// import 'package:dio/dio.dart';
// import 'package:stasht/network/api_call.dart';
// import 'package:stasht/network/api_callback.dart';

// class AwsS3Uploader {
//   final String bucketName;
//   final String region;
//   final String accessKeyId;
//   final String secretAccessKey;

//   AwsS3Uploader({
//     required this.bucketName,
//     required this.region,
//     required this.accessKeyId,
//     required this.secretAccessKey,
//   });

//   Future<String> generatePresignedUrl(
//       String objectKey, int expiryInSeconds) async {
//     final host = '$bucketName.s3.$region.amazonaws.com';
//     final date = DateTime.now().toUtc();
//     final amzDate =
//         '${date.toIso8601String().replaceAll('-', '').replaceAll(':', '').split('.').first}Z';
//     final dateStamp =
//         date.toIso8601String().split('T').first.replaceAll('-', '');

//     final credentialScope = '$dateStamp/$region/s3/aws4_request';
//     final canonicalHeaders = 'host:$host\nx-amz-date:$amzDate\n';
//     final signedHeaders = 'host;x-amz-date';

//     final canonicalRequest = '''
// PUT
// /$objectKey

// host:$host
// x-amz-date:$amzDate

// $signedHeaders
// UNSIGNED-PAYLOAD
// ''';

//     final stringToSign = '''
// AWS4-HMAC-SHA256
// $amzDate
// $credentialScope
// ${sha256.convert(utf8.encode(canonicalRequest))}
// ''';

//     final signingKey =
//         _getSignatureKey(secretAccessKey, dateStamp, region, 's3');
//     final signature = hmacSha256(signingKey, utf8.encode(stringToSign));

//     return 'https://$host/$objectKey?X-Amz-Algorithm=AWS4-HMAC-SHA256'
//         '&X-Amz-Credential=${Uri.encodeComponent(accessKeyId + '/' + credentialScope)}'
//         '&X-Amz-Date=$amzDate'
//         '&X-Amz-Expires=$expiryInSeconds'
//         '&X-Amz-SignedHeaders=$signedHeaders'
//         '&X-Amz-Signature=$signature';
//   }

//   List<int> _getSignatureKey(
//       String key, String dateStamp, String regionName, String serviceName) {
//     final kDate = hmacSha256(utf8.encode('AWS4$key'), utf8.encode(dateStamp));
//     final kRegion = hmacSha256(kDate, utf8.encode(regionName));
//     final kService = hmacSha256(kRegion, utf8.encode(serviceName));
//     return hmacSha256(kService, utf8.encode('aws4_request'));
//   }

//   List<int> hmacSha256(List<int> key, List<int> message) {
//     final hmac = Hmac(sha256, key);
//     return hmac.convert(message).bytes;
//   }

//   Future<void> uploadFile(String presignedUrl, File file,String type,ApiCallback callBack,String count) async {
//     print(presignedUrl);
//     final dio = Dio();
//     try {
//       final response = await dio.put(
//         presignedUrl,
//         data: file.openRead(),
//         options: Options(
//           headers: {
//             'Content-Type': 'application/octet-stream',
//           },
//         ),
//       );

//       if (response.statusCode == 200) {
//         print(response);
//         print('File uploaded successfully');
//         callBack.onSuccess(presignedUrl+"=$count", type);
//       } else {
//         callBack.onFailure("File upload failed with status code: ${response.statusCode}");
//       }
//     } catch (e) {
//               callBack.onFailure('Error uploading file: $e');

//       print('Error uploading file: $e');
//     }
//   }


//   // void uploadSingleImage() async {
//   //   String bucketName = "test";
//   //   String cognitoPoolId = "your pool id";
//   //   String bucketRegion = "imageUploadRegion";
//   //   String bucketSubRegion = "Sub region of bucket";

//   //   //fileUploadFolder - this is optional parameter
//   //   String fileUploadFolder =
//   //       "folder inside bucket where we want file to be uploaded";

//   //   String filePath = ""; //path of file you want to upload
//   //   ImageData imageData = ImageData("uniqueFileName", filePath,
//   //       uniqueId: "uniqueIdToTrackImage", imageUploadFolder: fileUploadFolder);

//   //   //result is either amazon s3 url or failure reason
//   //   String? result = await AmazonS3Cognito.upload(
//   //       bucketName, cognitoPoolId, bucketRegion, bucketSubRegion, imageData,
//   //       needMultipartUpload: true);
//   //   //once upload is success or failure update the ui accordingly
//   //   print(result);
//   // }

//   uploadAwsFile(File filepath, String bucketName1,
//    String region1,
//    String accessKeyId1,
//    String secretAccessKey1)async{
//     AwsS3.uploadFile(
//   accessKey: accessKeyId1,
//   secretKey: secretAccessKey1,
//   file: filepath, 
//   bucket: bucketName1,
//   region: region1,
// ).then((value) {
//   print("file:- $value");
// });
//   }
// }
