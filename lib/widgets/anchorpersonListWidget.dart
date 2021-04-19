import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tv/blocs/contact/bloc.dart';
import 'package:tv/blocs/contact/events.dart';
import 'package:tv/blocs/contact/states.dart';
import 'package:tv/helpers/exceptions.dart';
import 'package:tv/helpers/routeGenerator.dart';
import 'package:tv/models/contactList.dart';

class AnchorpersonListWidget extends StatefulWidget {
  @override
  _AnchorpersonListWidgetState createState() => _AnchorpersonListWidgetState();
}

class _AnchorpersonListWidgetState extends State<AnchorpersonListWidget> {

  @override
  void initState() {
    _fetchContactList();
    super.initState();
  }

  _fetchContactList() async {
    context.read<ContactBloc>().add(FetchContactList());
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width - 48- 15;

    return BlocBuilder<ContactBloc, ContactState>(
      builder: (BuildContext context, ContactState state) {
        if (state is ContactError) {
          final error = state.error;
          print('ContactError: ${error.message}');
          if( error is NoInternetException) {
            return error.renderWidget(onPressed: () => _fetchContactList());
          } 
          
          return error.renderWidget();
        }
        if (state is ContactListLoaded) {
          ContactList contactList = state.contactList;
          
          return Padding(
            padding: const EdgeInsets.only(
              left: 24-7.5, right: 24-7.5,
              top: 24-16.0, bottom: 24-16.0,
            ),
            child: _buildAnchorpersonList(contactList, width),
          );
        }

        // state is Init, loading, or other 
        return _loadingWidget();
      }
    );
  }

  Widget _loadingWidget() =>
      Center(
        child: CircularProgressIndicator(),
      );

  Widget _buildAnchorpersonList(ContactList contactList, double width) {
    double imageWidth = width/2;
    double imageHeight = imageWidth / 1.333;

    return GridView.builder(
      // shrinkWrap: true,
      // physics: NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(0),
      itemCount: contactList.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1 - 16/imageWidth,
      ),
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(7.5, 16, 7.5, 16),
          child: InkWell(
            child: Wrap(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: CachedNetworkImage(
                    height: imageHeight,
                    width: imageWidth,
                    imageUrl: contactList[index].photoUrl,
                    placeholder: (context, url) => Container(
                      height: imageHeight,
                      width: imageWidth,
                      color: Colors.grey,
                    ),
                    errorWidget: (context, url, error) => Container(
                      height: imageHeight,
                      width: imageWidth,
                      color: Colors.grey,
                      child: Icon(Icons.error),
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
                Center(
                  child: Text(
                    contactList[index].name,
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w400),
                  ),
                ),
              ]
            ),
            onTap: (){
              RouteGenerator.navigateToAnchorpersonStory(
                context, 
                contactList[index].id,
                contactList[index].name,
              );
            },
          ),
        );
      }
    );
  }
}