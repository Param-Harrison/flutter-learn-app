import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:wallpapers/constants.dart';

String buildUrl(String path, Map<String, dynamic> queryParams) {
    var queryString = '';
    queryParams.forEach((key, value) {
        queryString += '$key=$value&';
    });
    return '$ApiBase$path?client_id=$AccessToken&$queryString';
}

class Wallpaper {
    final String name;
    final String filename;

    const Wallpaper(this.name, this.filename);
}

class User {
    String id;
    String firstName;
    String lastName;
    Map<String, String> profileImage;
    Map<String, String> links;

    User(this.id, this.firstName, this.lastName, this.profileImage, this.links);

    User.fromJson(Map<String, dynamic> json) {
        this.id = json['id'];
        this.firstName = json['first_name'];
        this.lastName = json['last_name'];
        this.profileImage = Map.from(json['profile_image']);
        this.links = Map.from(json['links']);
    }

    String get fullName {
        return '$firstName $lastName';
    }
}

class Photo {
    String id;
    String color;
    int width;
    int height;
    String description;
    Map<String, String> urls;
    Map<String, String> links;
    int likes;
    User user;

    Photo.fromJson(Map<String, dynamic> json) {
        this.id = json['id'];
        this.color = json['color'];
        this.width = json['width'];
        this.height = json['height'];
        this.description = json['description'];
        this.urls = Map.from(json['urls']);
        this.links = Map.from(json['links']);
        this.likes = json['likes'];
        this.user = User.fromJson(json['user']);
    }

    static Future<List<Photo>> getCurated([page = 1, perPage = 8]) async {
        return Photo.fetch('/photos/curated/', page, perPage);
    }

    static Future<List<Photo>> getByCategory(Category category, [page = 1, perPage = 8]) async {
        return Photo.fetch('/collections/${category.id}/photos', page, perPage);
    }

    static Future<List<Photo>> fetch(path, [page = 1, perPage = 9]) async {
        var url = buildUrl(path, {
            "page": page, "per_page": perPage
        });
        final response = await http.get(url);
        if (response.statusCode == 200) {
            List<dynamic> items = json.decode(response.body);
            return items.map((value) => Photo.fromJson(Map.from(value))).toList();
        } else {
            throw new Exception('Error loading photos list.');
        }
    }

    String thumb() {
        return this.urls['small'];
    }

    String regular() {
        return this.urls['regular'];
    }
}

class Category {
    int id;
    String title;
    String description;
    int totalPhotos;
    Photo coverPhoto;
    User user;
    Map<String, String> links;

    Category.fromJson(Map<String, dynamic> json) {
        id = json['id'];
        title = json['title'];
        description = json['description'];
        totalPhotos = json['total_photos'];
        coverPhoto = Photo.fromJson(json['cover_photo']);
        user = User.fromJson(json['user']);
        links = Map.from(json['links']);
    }

    static Future<List<Category>> getFeatured([page = 1, perPage = 8]) async {
        var url = buildUrl('/collections/featured', {
            "page": page, "per_page": perPage
        });
        final response = await http.get(url);
        if (response.statusCode == 200) {
            List<dynamic> items = json.decode(response.body);
            return items.map((value) => Category.fromJson(Map.from(value))).toList();
        } else {
            throw new Exception('Error loading categories list.');
        }
    }

}