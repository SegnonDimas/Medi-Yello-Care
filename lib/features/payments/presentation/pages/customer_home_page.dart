import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import 'customer_transactions_tab.dart';
import '../../../feedbacks/presentation/pages/feedback_tab.dart';
import 'qr_scanner_page.dart';
import '../../../../core/theme/app_colors.dart';

class CustomerHomePage extends StatefulWidget {
  const CustomerHomePage({super.key});

  @override
  State<CustomerHomePage> createState() => _CustomerHomePageState();
}

class _CustomerHomePageState extends State<CustomerHomePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Image.asset("assets/icon/icon.png"),
        title: const Text('Mes Services Santé', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.primary,),
            onPressed: () {
              showCupertinoModalPopup(context: context, builder: (context){
                return CupertinoAlertDialog(
                  title: Text("Deconnexion"),
                  content: Text("Voulez-vous vraiment vous déconnecter ?"),
                  actions: [

                    CupertinoDialogAction(
                      isDestructiveAction: true,
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text("Annuler", style: TextStyle(color: AppColors.lightTextSecondary,)),
                    ),
                    CupertinoDialogAction(
                      isDefaultAction: true,
                      onPressed: () {
                        context.read<AuthBloc>().add(AuthSignOutRequested());
                        Navigator.pop(context);
                      },
                      child: Text("Confirmer", /*style: TextStyle(color: AppColors.primary)*/),
                    ),

                  ],
                );
              });
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          indicatorWeight: 5,
          indicatorSize: TabBarIndicatorSize.tab,
          unselectedLabelColor: AppColors.primary.withOpacity(.5),
          labelStyle: TextStyle(fontWeight: FontWeight.w900, fontSize:16 ),
          tabs: const [
            Tab(icon: Icon(Icons.wallet), text: 'Paiements'),
            Tab(icon: Icon(Icons.wechat), text: 'Avis'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          CustomerTransactionsTab(),
          FeedbackTab(),
        ],
      ),

    );
  }
}
