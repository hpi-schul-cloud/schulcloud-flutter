import 'package:provider/provider.dart';

import 'package:flutter/material.dart';

import 'package:schulcloud/app/services.dart';
import 'package:schulcloud/app/services/files.dart';
import 'package:schulcloud/app/widgets.dart';
import 'package:schulcloud/app/widgets/files_view.dart';

class FilesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ProxyProvider<ApiService, FilesService>(
      builder: (_, api, __) => FilesService(api: api, ownerType: 'user'),
      child: Scaffold(
        body: FilesView(ownerType: 'user'),
        bottomNavigationBar: MyAppBar(),
      ),
    );
  }
}
