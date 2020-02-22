import 'src/libmikack.dart' as libmikack;
import 'src/models.dart' as models;

List<models.Platform> platforms() => libmikack.platforms().asList();
