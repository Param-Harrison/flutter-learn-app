import 'dart:async';

import 'package:flutter/material.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:wallpapers/models.dart';
import 'package:wallpapers/screens/preview.dart';


class PhotoItem extends StatelessWidget {
    @required
    final Photo photo;

    @required
    final GestureTapCallback onTap;
    final EdgeInsetsGeometry padding;
    const PhotoItem({Key key, this.photo, this.onTap, this.padding}) : super(key: key);

    @override
    Widget build(BuildContext context) {
        return new Container(
            child: new GestureDetector(
                onTap: onTap,
                child: new ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(6.0)),
                    child: new FadeInImage.memoryNetwork(
                        placeholder: kTransparentImage,
                        image: photo.thumb(),
                        fit: BoxFit.cover,
                    ),
                )
            )
        );
    }
}

class PhotosListViewState extends State<PhotosListView> {
    List<Photo> items = [];
    ScrollController _scrollController;
    int page = 0;
    int loadBefore = 50;
    bool isLoading = false;
    double scrollPosition = 0.0;
    Category category;

    PhotosListViewState([this.category]) : super();

    @override
    void initState() {
        super.initState();

        items = [];
        _loadPhotos();
        _scrollController = new ScrollController(
            initialScrollOffset: scrollPosition
        );
        _scrollController.addListener(() {
            var loadPoint = _scrollController.position.maxScrollExtent - loadBefore;
            if (_scrollController.position.pixels >= loadPoint) {
                _loadPhotos();
            }
            scrollPosition = _scrollController.position.pixels;
        });
    }

    @override
    void dispose() {
        _scrollController.dispose();
        super.dispose();
    }

    _loadPhotos() async {
        if (!isLoading) {
            setState(() {
                isLoading = true;
            });
            page += 1;
            var newPhotos;
            if (category == null) {
                newPhotos = await Photo.getCurated(page);
            } else {
                newPhotos = await Photo.getByCategory(category, page);
            }
            setState(() {
                items.addAll(newPhotos);
                isLoading = false;
            });
        }
        return new Future.value(items);
    }

    @override
    Widget build(BuildContext context) {
        return new Container(
            color: Colors.white,
            child: new Container(
                child: GridView.count(
                    padding: EdgeInsets.all(6.0),
                    crossAxisCount: 2,
                    crossAxisSpacing: 6.0,
                    mainAxisSpacing: 6.0,
                    childAspectRatio: 4.0 / 4.0,
                    controller: _scrollController,
                    children: List.generate(items.length, (index) {
                        if (index == items.length) {
                            return new CircularProgressIndicator();
                        }

                        Photo photo = items[index];
                        return PhotoItem(
                            photo: photo,
                            onTap: () {
                                Navigator.push(context, MaterialPageRoute(
                                    builder: (context) => new PreviewScreen(photo: photo),
                                ));
                            },
                        );
                    }),
                ),
            )
        );
    }

}

class PhotosListView extends StatefulWidget {
    final Category category;

    PhotosListView({Key key, this.category}) : super(key: key);

    @override
    State<StatefulWidget> createState() {
        return new PhotosListViewState(category);
    }
}