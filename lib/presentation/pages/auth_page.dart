import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app_slb/data/repository/auth_repository.dart';
import 'package:mobile_app_slb/presentation/widgets/black_button.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_scanner_overlay/qr_scanner_overlay.dart';
import 'home_page.dart';

class AuthPage extends ConsumerStatefulWidget {
  const AuthPage({super.key});

  @override
  ConsumerState<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends ConsumerState<AuthPage> {
  MobileScannerController cameraController = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates, detectionTimeoutMs: 250);
  double _currentSliderValue = 0;
  bool isError = false;
  bool isLoading = false;

  @override
  void initState() {
    cameraController.stop();
    super.initState();
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: Column(
        children: [
          Expanded(
            flex: 1,
            child: Center(
                child: Image.asset(
              "assets/images/logo.png",
              scale: 4,
            )),
          ),
          Expanded(
            flex: 3,
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: MobileScanner(
                      fit: BoxFit.cover,
                      controller: cameraController,
                      placeholderBuilder: (context, widget) => const Center(
                            child: CircularProgressIndicator(
                              color: Colors.black,
                            ),
                          ),
                      onDetect: (capture) async {
                        final List<Barcode> barcodes = capture.barcodes;
                        setState(() {
                          isLoading = true;
                        });
                        AuthRepository().loginUser(barcodes[0].rawValue!).then((value) {
                          if (value.errorModel == null &&
                              value.authModel != null) {
                            Future.microtask(() => Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                    builder: (builder) => const HomePage()),
                                    (route) => false));
                          } else {
                            setState(() {
                              isError = true;
                            });
                          }
                          setState(() {
                            isLoading = false;
                          });
                        });
                      }),
                ),
                QRScannerOverlay(
                  overlayColor: Colors.white,
                  borderColor: Colors.black,
                  scanAreaHeight: 320,
                  scanAreaWidth: 320,
                )
              ],
            ),
          ),
          Expanded(
              flex: 2,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  isLoading
                      ? const Center(
                          child: CircularProgressIndicator(color: Colors.black,),
                        )
                      : Container(),
                  isError && !isLoading
                      ? const Padding(
                          padding: EdgeInsets.only(left: 50, right: 50),
                          child: Text(
                            "Something went wrong. Try to re-scan again",
                            style: TextStyle(
                                fontWeight: FontWeight.normal,
                                fontSize: 17,
                                color: Color(0xFFFF0000)),
                            textAlign: TextAlign.center,
                          ),
                        )
                      : Container(),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.only(left: 50, right: 50),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "-",
                          style: TextStyle(fontSize: 40, color: Colors.grey),
                        ),
                        Expanded(
                          child: Slider(
                            value: _currentSliderValue,
                            min: 0,
                            max: 1,
                            activeColor: Colors.black,
                            inactiveColor: Colors.grey,
                            label: _currentSliderValue.round().toString(),
                            onChanged: (double value) {
                              if (value < 0.1) {
                                cameraController.resetZoomScale();
                              } else {
                                cameraController.setZoomScale(value);
                              }
                              setState(() {
                                _currentSliderValue = value;
                              });
                            },
                          ),
                        ),
                        const Text("+",
                            style: TextStyle(fontSize: 40, color: Colors.grey))
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.only(left: 50, right: 50),
                    child: blackButton(
                        null,
                        ValueListenableBuilder(
                          valueListenable: cameraController.torchState,
                          builder: (context, state, child) {
                            switch (state) {
                              case TorchState.off:
                                return const Icon(Icons.flash_off,
                                    color: Colors.grey);
                              case TorchState.on:
                                return const Icon(Icons.flash_on,
                                    color: Colors.white);
                            }
                          },
                        ), () {
                      cameraController.toggleTorch();
                    }),
                  ),
                ],
              ))
        ],
      ),
    ));
  }
}