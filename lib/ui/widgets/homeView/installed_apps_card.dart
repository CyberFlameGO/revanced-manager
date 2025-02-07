import 'package:device_apps/device_apps.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:revanced_manager/app/app.locator.dart';
import 'package:revanced_manager/models/patched_application.dart';
import 'package:revanced_manager/services/manager_api.dart';
import 'package:revanced_manager/ui/views/home/home_viewmodel.dart';
import 'package:revanced_manager/ui/widgets/shared/application_item.dart';
import 'package:revanced_manager/ui/widgets/shared/custom_card.dart';

class InstalledAppsCard extends StatefulWidget {
  const InstalledAppsCard({Key? key}) : super(key: key);

  @override
  State<InstalledAppsCard> createState() => _InstalledAppsCardState();
}

class _InstalledAppsCardState extends State<InstalledAppsCard> {
  List<PatchedApplication> apps = locator<HomeViewModel>().patchedInstalledApps;
  final ManagerAPI _managerAPI = locator<ManagerAPI>();
  List<PatchedApplication> patchedApps = [];

  @override
  void initState() {
    super.initState();
    _getApps();
  }

  Future _getApps() async {
    if (apps.isNotEmpty) {
      patchedApps = [...apps];
      for (final element in apps) {
        await DeviceApps.getApp(element.packageName).then((value) {
          if (element.version != value?.versionName) {
            patchedApps.remove(element);
          }
        });
      }
      if (apps.length != patchedApps.length) {
        await _managerAPI.setPatchedApps(patchedApps);
        apps.clear();
        apps = [...patchedApps];
      }
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return apps.isEmpty
        ? CustomCard(
            child: Center(
              child: Column(
                children: <Widget>[
                  Icon(
                    size: 40,
                    Icons.file_download_off,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  const SizedBox(height: 16),
                  I18nText(
                    'homeView.noInstallations',
                    child: Text(
                      '',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                    ),
                  )
                ],
              ),
            ),
          )
        : ListView(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            children: apps
                .map(
                  (app) => ApplicationItem(
                    icon: app.icon,
                    name: app.name,
                    patchDate: app.patchDate,
                    changelog: app.changelog,
                    isUpdatableApp: false,
                    onPressed: () =>
                        locator<HomeViewModel>().navigateToAppInfo(app),
                  ),
                )
                .toList(),
          );
  }
}
