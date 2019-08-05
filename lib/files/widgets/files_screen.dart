import 'package:provider/provider.dart';

import 'package:flutter/material.dart';

import 'package:schulcloud/app/services.dart';
import 'package:schulcloud/app/widgets.dart';
import 'package:schulcloud/files/widgets/files_view.dart';

import '../bloc.dart';

class FilesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ProxyProvider<ApiService, Bloc>(
      builder: (_, api, __) => Bloc(api: api),
      child: Scaffold(
        body: FilesView(),
        bottomNavigationBar: MyAppBar(),
      ),
    );
  }
}
