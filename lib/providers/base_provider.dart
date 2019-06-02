import 'package:fibre_balance_check/common/usage.dart';
import 'dart:async';

abstract class BaseProvider {
  String getName();
  Future<bool> login(String username, String password);
  Future<List<String>> getProductList();
  Future<Usage> getUsage(String productId);
}