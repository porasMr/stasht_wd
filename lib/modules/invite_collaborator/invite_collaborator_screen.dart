import 'package:flutter/material.dart';
import 'package:flutter_contacts/contact.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:stasht/modules/media/model/phot_mdoel.dart';
import 'package:stasht/modules/photos/photos_screen.dart';
import 'package:stasht/utils/app_colors.dart';
import 'package:stasht/utils/app_strings.dart';
import 'package:stasht/utils/assets_images.dart';
import 'package:stasht/utils/common_widgets.dart';
import 'package:stasht/utils/constants.dart';
import 'package:http/http.dart' as http;

class InviteCollaborator extends StatefulWidget {
  InviteCollaborator(
      {super.key,
      required this.memoryId,
      required this.title,
      required this.image,
      required this.photosList});
  String memoryId = "";
  String title = "";
  String image = "";
  List<PhotoModel> photosList = [];

  @override
  InviteCollaboratorState createState() => InviteCollaboratorState();
}

class InviteCollaboratorState extends State<InviteCollaborator> {
  List<Contact> contactsList = [];
  List<Contact> filteredContactsList = [];
  List<Contact> selectedContacts = [];
  var selectedIndex = [];
  bool permissionDenied = false;
   String accountSid ='';
    String authToken = '';
     
  @override
  void initState() {
    fetchContacts();
    accountSid=dotenv.env['TWILIO_ACCOUNT_SID'] ?? 'No SID';
    authToken=dotenv.env['TWILIO_AUTH_TOKEN'] ?? 'No Token';
    print('$accountSid  $authToken' );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showInviteCollabDialog(context);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppStrings.inviteCollab,
          style: appTextStyle(fm: robotoRegular, fz: 22, height: 28 / 22),
        ),
        leading: null,
        actions: [
          GestureDetector(
            onTap: () async {
              String baseUrl =
                  "https://stasht-data.s3.us-east-2.amazonaws.com/images/";
              String imageIdentifier = widget.image.replaceFirst(baseUrl, "");
              String link = await CommonWidgets.createDynamicLink(
                  widget.memoryId, widget.title, imageIdentifier);
              if (link.isNotEmpty) {
                for (var element in selectedContacts) {
                  sendLinkBySms(
                      phoneNumber: element.phones.first.normalizedNumber,
                      link: Uri.parse(link),
                      title: TextEditingController(text: widget.title));
                }
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) => PhotosView(
                              photosList: widget.photosList,
                              isSkip: false,
                            )));
              }
            },
            child: Padding(
              padding: const EdgeInsets.only(right: 15.0),
              child: Text(
                AppStrings.done,
                style: appTextStyle(
                    color: AppColors.primaryColor, fm: robotoRegular, fz: 22),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _sreachFiled(context),
          permissionDenied == true
              ? const Center(child: Text('Permission denied'))
              : _contactListView(context)
        ],
      ),
    );
  }

  _contactListView(BuildContext context) {
    return Expanded(
        child: ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      shrinkWrap: true,
      itemCount: filteredContactsList.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                        height: 40,
                        width: 40,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primaryColor),
                        child:
                            (filteredContactsList[index].photo ?? []).isNotEmpty
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(40),
                                    child: Image.memory(
                                        filteredContactsList[index].photo!),
                                  )
                                : Text(
                                    filteredContactsList[index]
                                        .displayName[0]
                                        .toUpperCase(),
                                    style: appTextStyle(
                                        fm: robotoBold,
                                        fz: 17,
                                        color: Colors.white),
                                  )
                        // Image.memory(filteredContactsList.isNotEmpty?
                        // filteredContactsList[index].avatar!:contactsList[index].avatar!),
                        ),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            filteredContactsList[index].displayName ?? "",
                            style: appTextStyle(
                              fm: robotoRegular,
                              height: 18 / 17,
                              fz: 17,
                            ),
                          ),
                          Text(
                            filteredContactsList[index].phones.isNotEmpty
                                ? filteredContactsList[index]
                                    .phones
                                    .first
                                    .normalizedNumber
                                : "",
                            style: appTextStyle(
                                fm: robotoRegular,
                                height: 18 / 14,
                                fz: 14,
                                color: AppColors.lightGrey),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  // Use the unique contact identifier, e.g., the phone number or display name
                  var selectedContact = filteredContactsList[index];
                  if (selectedContacts.contains(selectedContact)) {
                    // If the contact is already selected, remove it from the selected list
                    selectedContacts.remove(selectedContact);
                  } else {
                    // If not, add it to the selected list
                    selectedContacts.add(selectedContact);
                  }
                  setState(() {
                    
                  });
                },
                child: Container(
                  height: 20,
                  width: 20,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color:
                          selectedContacts.contains(filteredContactsList[index])
                              ? const Color(0XFF65558F)
                              : AppColors.dialogMiddleFontColor,
                      width: 1.5,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.circle,
                    size: 13,
                    color:
                        selectedContacts.contains(filteredContactsList[index])
                            ? const Color(0XFF65558F)
                            : Colors.transparent,
                  ),
                ),
              )
            ],
          ),
        );
      },
    ));
  }

  _sreachFiled(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 30, right: 30, top: 20, bottom: 20),
      height: 30,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15), color: Color(0XFFEFEFEF)),
      child: TextFormField(
        onChanged: (value) {
          searchContacts(value);
        },
        decoration: InputDecoration(
            contentPadding: const EdgeInsets.only(top: -7.5),
            hintText: AppStrings.search,
            hintStyle: appTextStyle(
                fz: 16, fm: robotoRegular, color: const Color(0XFF8A8A8D)),
            border: InputBorder.none,
            prefixIcon: Transform.scale(
              scale: .7,
              child: Image.asset(
                search,
              ),
            )),
      ),
    );
  }

  String searchTerm = '';

  void searchContacts(String query) {
    searchTerm = query;
    filteredContactsList = contactsList
        .where((contact) =>
            contact.displayName.toLowerCase().contains(query.toLowerCase()))
        .toList();
    setState(() {});
  }

  Future fetchContacts() async {
    if (!await FlutterContacts.requestPermission(readonly: true)) {
      permissionDenied = true;
      setState(() {});
    } else {
      final contacts = await FlutterContacts.getContacts(
          withPhoto: true, withProperties: true);
      contactsList = contacts;
      filteredContactsList = contacts;
      for (int i = 0; i < filteredContactsList.length; i++) {
        print('photo=== ${filteredContactsList[i].photo}');
        print('photo thumb=== ${filteredContactsList[i].photoOrThumbnail}');
        print(
            'name===${filteredContactsList[i].phones.isNotEmpty ? filteredContactsList[i].phones.first.normalizedNumber : ''}');

        print('name===${filteredContactsList[i].displayName}');
      }
    }
    EasyLoading.dismiss();
  }

  sendLinkBySms(
      {String? phoneNumber,
      Uri? link,
      required TextEditingController title}) async {
    

     
  }

  showInviteCollabDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: AppColors.textfieldFillColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          child: Container(
            width: 312,
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            height: 312,
            // Add padding for spacing
            decoration: BoxDecoration(
              color: AppColors.textfieldFillColor,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              // Center content vertically
              children: [
                const SizedBox(
                  height: 25,
                ),
                Text(
                  AppStrings.memoryMeantToShare,
                  style: appTextStyle(
                    fz: 24,
                    height: 32 / 24,
                    fm: robotoRegular,
                  ),
                  textAlign: TextAlign.left,
                ),
                const SizedBox(height: 16), // Add spacing between elements
                Text(
                  "Invite friends to share in the memory.\n Once they receive the invite link they will \nbe able to contribute by stashing their \nphotos to your memory. ",
                  style: appTextStyle(
                    fz: 14,
                    height: 20 / 14,
                    fm: robotoRegular,
                    color: AppColors.dialogMiddleFontColor,
                  ),
                  textAlign: TextAlign.justify,
                ),
                const SizedBox(
                    height: 30), // Add spacing before the close button
                Container(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        AppStrings.close,
                        style: appTextStyle(
                          fz: 14,
                          height: 20 / 14,
                          fm: robotoMedium,
                          color: AppColors.primaryColor,
                        ),
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
