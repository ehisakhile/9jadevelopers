import 'package:html/parser.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class CheckLink {
  static String checkYouTubeLink(String htmlString) {
    print("hgello vishal 789");
    print(htmlString);

    if (htmlString.contains("https://www.youtube.com/") ||
        htmlString.contains("https://youtu.be") ||
        htmlString.contains("https://m.youtube.com/") ||
        htmlString.contains("www.youtube.com") ||
        htmlString.contains("https://") ||
        htmlString.contains("www.")) {
      // if(htmlString.substring(0, 7) ==  "") {
      final document = parse(htmlString);
      final String parsedString =
          parse(document.body!.text).documentElement!.text;
      print(parsedString);
      print("hgello vishal 789789");

      if (parsedString.contains("https://www.youtube.com/") ||
          parsedString.contains("https://youtu.be") ||
          parsedString.contains("https://m.youtube.com/") ||
          parsedString.contains("www.youtube.com") ||
          parsedString.contains("https://") ||
          parsedString.contains("www.")) {
        return parsedString;
      } else {
        return '';
      }
    } else {
      return '';
    }
  }

  static bool isValidYoutubeLink(String url) =>
      YoutubePlayerController.convertUrlToId(url) != null;
  static bool isYoutubeLink(String url) {
    return url.contains("https://www.youtube.com/") ||
        url.contains("https://youtu.be") ||
        url.contains("https://m.youtube.com/") ||
        url.contains("www.youtube.com");
  }

  static removeHtmlTag(String? title) {
    final document = parse(title);
    final String parsedString =
        parse(document.body!.text).documentElement!.text;
    return parsedString;
  }
}
