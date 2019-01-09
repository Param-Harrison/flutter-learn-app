import 'dart:async';

import 'package:flutter/material.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:wallpapers/models.dart';
import 'package:wallpapers/widgets/photos.dart';

class CategoryItem extends StatelessWidget {
    final Category category;

    CategoryItem({Key key, this.category}) : super(key: key);

    @override
    Widget build(BuildContext context) {
        return new Container(
            height: 230.0,
            child: GestureDetector(
                onTap: () {
                    Navigator.push(context, MaterialPageRoute(
                        builder: (context) => CategoryDetailsView(category: category)
                    ));
                },
                child: new ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(6.0)),
                    child: new Material(
                        elevation: 8.0,
                        child: Stack(
                            fit: StackFit.expand,
                            alignment: Alignment.topLeft,
                            children: <Widget>[
                                FadeInImage.memoryNetwork(
                                    placeholder: kTransparentImage,
                                    image: category.coverPhoto.thumb(),
                                    fit: BoxFit.cover,
                                ),
                                Container(
                                    color: Colors.black45,
                                    padding: EdgeInsets.only(bottom: 16.0, left: 16.0),
                                    child: Column(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                            Text('${category.totalPhotos} photos',
                                                style: TextStyle(
                                                    fontSize: 16.0,
                                                    color: Colors.white
                                                )
                                            ),
                                            Text('${category.title}', style: TextStyle(
                                                fontSize: 24.0,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white
                                            )),
                                        ],
                                    ),
                                )
                            ],
                        )
                    ),
                ),
            ),
        );
    }

}


class CategoriesViewState extends State<CategoriesView> {
    ScrollController _scrollController;
    List<Category> items = [];
    int page = 0;
    int loadBefore = 50;
    bool isLoading = false;

    void initState() {
        super.initState();
        items = [];
        _load();
        _scrollController = new ScrollController();
        _scrollController.addListener(() {
            var loadPoint = _scrollController.position.maxScrollExtent - loadBefore;
            if (_scrollController.position.pixels >= loadPoint) {
                _load();
            }
        });
    }

    @override
    void dispose() {
        _scrollController.dispose();
        super.dispose();
    }

    _load() async {
        if (!isLoading) {
            setState(() {
                isLoading = true;
            });
            page += 1;
            var newItems = await Category.getFeatured(page);
            setState(() {
                items.addAll(newItems);
                isLoading = false;
            });
        }
        return new Future.value(items);
    }

    @override
    Widget build(BuildContext context) {
        return new Container(
            padding: EdgeInsets.all(8.0),
            child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (BuildContext context, int index) {
                    var photo = items[index];
                    return new Container(
                        padding: EdgeInsets.only(bottom: 8.0),
                        child: CategoryItem(
                            category: photo,
                        ),
                    );
                },
            ),
        );
    }

}

class CategoriesView extends StatefulWidget {
    CategoriesView({Key key}) : super(key: key);

    @override
    State<StatefulWidget> createState() {
        return new CategoriesViewState();
    }
}


class CategoryDetailsView extends StatelessWidget {
    final Category category;

    CategoryDetailsView({Key key, this.category}) : super(key: key);

    @override
    Widget build(BuildContext context) {
        return new Scaffold(
            appBar: AppBar(
                title: Text(
                    category.title,
                ),
            ),
            body: PhotosListView(category: category),
        );
    }
}