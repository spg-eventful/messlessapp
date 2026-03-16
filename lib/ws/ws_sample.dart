class Service {
  Service({required this.name});

  final String name;

  Future<T?> create<T>(dynamic data) async {
    return null;
  }

  void get() {}

  void find() {}
}

class BackendClient {
  Service service(String name) {
    return Service(name: name);
  }
}

class UserDto {
  UserDto(this.email);

  final String email;
}

class BasicAuth {
  BasicAuth(this.email, this.password);

  final String email;
  final String password;
}

void test() async {
  var client = BackendClient();
  await client
      .service("echo")
      .create<UserDto>(BasicAuth("hello@world.net", "banane"));
}
