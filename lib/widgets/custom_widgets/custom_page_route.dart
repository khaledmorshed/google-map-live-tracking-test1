import 'package:flutter/cupertino.dart';

class CustomPageRoute extends PageRouteBuilder{
  final Widget child;
  final AxisDirection direction;

  CustomPageRoute({
    required this.child,
    this.direction = AxisDirection.right,
    RouteSettings? settings,
  }) : super(
    transitionDuration: const Duration(milliseconds: 300),
    reverseTransitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, animation, secondaryAnimation) => child,
    settings: settings,
  );

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget buildTransitions(
      BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) =>
      SlideTransition(
        position: Tween<Offset>(
          begin: getBeginOffset(),
          end: Offset.zero,
        ).animate(animation),
        child: child,
      );
  Offset getBeginOffset(){
    switch(direction){
      case AxisDirection.up:
        return const Offset(0, 1);
      case AxisDirection.down:
        return const Offset(0, -1);
      case AxisDirection.right:
        return const Offset(-1, 0);
      case AxisDirection.left:
        return const Offset(1, 0);
    }
  }
}