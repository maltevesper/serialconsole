import 'package:flutter/material.dart';

class Console extends LeafRenderObjectWidget {
  const Console({super.key});

  @override
  LeafRenderObjectElement createElement() {
    return ConsoleElement(this);
  }

  @override
  RenderObject createRenderObject(BuildContext context) {
    return ConsoleRenderObject();
  }
}

class ConsoleElement extends LeafRenderObjectElement {
  ConsoleElement(Console super.widget);
}

class ConsoleRenderObject extends RenderBox {
  @override
  bool get sizedByParent => true;

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    return constraints.biggest;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    super.paint(context, offset);
    context.canvas.drawColor(Colors.blue, BlendMode.src);

    TextSpan myText = const TextSpan(
      text: 'Hello world!',
      style: TextStyle(color: Colors.black),
    );

    TextPainter p = TextPainter(text: myText, textDirection: TextDirection.ltr);
    p.layout();
    Offset textposition = size.center(offset) - p.size.center(Offset.zero);
    p.paint(context.canvas, textposition);
  }
}
