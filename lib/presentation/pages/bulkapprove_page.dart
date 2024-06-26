import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app_slb/data/models/stock_model.dart';
import 'package:mobile_app_slb/presentation/pages/bulkcomplete_page.dart';
import 'package:mobile_app_slb/presentation/states/bulk_state.dart';
import '../../data/models/bulksorted_model.dart';
import '../widgets/app_drawer.dart';
import '../widgets/backButton.dart';
import '../widgets/exit_dialog.dart';
import 'home_page.dart';

class BulkApprovePage extends ConsumerStatefulWidget {
  const BulkApprovePage(
      {super.key, required this.bulkModels, required this.stockModel});

  final List<BulkSortedModel> bulkModels;
  final StockModel stockModel;

  @override
  ConsumerState<BulkApprovePage> createState() => _BulkApprovePageState();
}

class _BulkApprovePageState extends ConsumerState<BulkApprovePage>
    with WidgetsBindingObserver {
  var scaffoldKey = GlobalKey<ScaffoldState>();
  bool isExitOpened = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      if (!isExitOpened) {
        setState(() {
          isExitOpened = true;
        });
        showDialog(
            context: context,
            builder: (context) {
              return exitDialog(
                  context, AppLocalizations.of(context)!.bulkLeave);
            }).then((returned) {
          if (returned) {
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const HomePage()),
                (route) => false);
          }
        }).then((value) => setState(() {
              isExitOpened = false;
            }));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
          textScaler: MediaQuery.of(context).size.shortestSide > 650
              ? const TextScaler.linear(1.1)
              : const TextScaler.linear(1.0)),
      child: Scaffold(
          key: scaffoldKey,
          resizeToAvoidBottomInset: false,
          endDrawer: AppDrawer(
            isAbleToNavigate: false,
            isAssembly: false,
            isHomePage: false,
            stockModel: widget.stockModel,
          ),
          bottomNavigationBar: SafeArea(
            child: Container(
                height: 80,
                decoration: const BoxDecoration(
                    border: Border(
                        top: BorderSide(color: Color(0xFFD9D9D9), width: 1))),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(
                      child: Opacity(
                        opacity: 1.0,
                        child: InkWell(
                          onTap: () async {
                            for (var element in widget.bulkModels) {
                              await ref
                                  .read(bulkProvider)
                                  .approveAssembly(element.assemblyModel.id);
                              // if (data.errorModel != null) {
                              //   ref.read(deleteAuthProvider).deleteAuth();
                              //   Future.microtask(() =>
                              //       Navigator.pushAndRemoveUntil(
                              //           context,
                              //           MaterialPageRoute(
                              //               builder: (context) =>
                              //                   const AuthPage()),
                              //           (route) => false));
                              // }
                            }
                            if (context.mounted) {
                              ref.refresh(getBulkProvider).value;
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const BulkCompletePage()));
                            }
                          },
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Center(
                                child: Container(
                                  width: 68,
                                  height: 68,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(50),
                                      color: const Color(0xFFDFDFDF)),
                                ),
                              ),
                              Center(
                                child: Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(50),
                                        color: Colors.black),
                                    child: Center(
                                      child: Image.asset(
                                        "assets/images/bulk_approve_icon.png",
                                        scale: 4,
                                      ),
                                    )),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                )),
          ),
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.only(
                        top: 40, right: 40, left: 40, bottom: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            backButton(() {
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return exitDialog(
                                        context,
                                        AppLocalizations.of(context)!
                                            .bulkLeave);
                                  }).then((returned) {
                                if (returned) {
                                  Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const HomePage()),
                                      (route) => false);
                                }
                              });
                            }, AppLocalizations.of(context)!.cancelCaps, false),
                            Builder(builder: (context) {
                              return InkWell(
                                onTap: () {
                                  Scaffold.of(context).openEndDrawer();
                                },
                                child: Container(
                                  width: 30,
                                  height: 30,
                                  decoration: BoxDecoration(
                                      color: const Color(0xFF3C3C3C),
                                      borderRadius: BorderRadius.circular(5)),
                                  child: const Icon(
                                    Icons.menu,
                                    color: Colors.white,
                                  ),
                                ),
                              );
                            }),
                          ],
                        ),
                        const Spacer(),
                        Text(
                          AppLocalizations.of(context)!.bulkAssemblyCaps,
                          style: const TextStyle(
                              fontSize: 24,
                              color: Color(0xFF909090),
                              height: 0.5),
                        ),
                        Text(
                          AppLocalizations.of(context)!.orders,
                          style: const TextStyle(
                              fontSize: 36,
                              color: Color(0xFF363636),
                              fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
                const Divider(
                  height: 1,
                ),
                Expanded(
                  flex: 6,
                  child: getProductListWidget(widget.bulkModels, width),
                ),
                const Center(child: VerticalDivider()),
              ],
            ),
          )),
    );
  }

  Widget getProductListWidget(List<BulkSortedModel> data, double width) {
    return Column(
      children: [
        Container(
          height: 56,
          decoration: const BoxDecoration(color: Colors.black),
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: Center(
                  child: Text(
                    AppLocalizations.of(context)!.nameCaps,
                    style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        fontSize: 16),
                  ),
                ),
              ),
              const VerticalDivider(
                color: Color(0xFFD9D9D9),
              ),
              Expanded(
                flex: 1,
                child: Center(
                  child: Text(
                    AppLocalizations.of(context)!.quantityCaps,
                    style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
            flex: 5,
            child: ListView(
              children: data.mapIndexed((index, e) {
                return SizedBox(
                  height: 58 * e.cartModel.length.toDouble() + 26,
                  child: Column(
                    children: [
                      Container(
                        height: 26,
                        width: double.infinity,
                        decoration:
                            const BoxDecoration(color: Color(0xFFEBEBEB)),
                        child: Center(
                          child: Text(
                            "${AppLocalizations.of(context)!.orderCaps}${e.assemblyModel.id}",
                            style: const TextStyle(fontSize: 16),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      Expanded(
                        child: ListView(
                          physics: const NeverScrollableScrollPhysics(),
                          children: e.cartModel.mapIndexed((index, e) {
                            return Container(
                              height: 58,
                              decoration: BoxDecoration(
                                  color: index % 2 == 0
                                      ? const Color(0xFFF9F9F9)
                                      : Colors.white),
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(left: 10, right: 10),
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 1,
                                      child: SizedBox(
                                        width: width / 2,
                                        child: Center(
                                          child: Text(
                                            e.model.name,
                                            style: const TextStyle(
                                                fontSize: 16,
                                                color: Color(0xFF222222)),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const VerticalDivider(),
                                    Expanded(
                                      flex: 1,
                                      child: SizedBox(
                                        width: width / 2,
                                        child: Center(
                                          child: Text(
                                            e.quantity.toString(),
                                            style: const TextStyle(
                                                fontSize: 16,
                                                color: Color(0xFF222222)),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      )
                    ],
                  ),
                );
              }).toList(),
            )),
      ],
    );
  }
}
