import 'package:flutter/material.dart';

class BookReadingScreen extends StatefulWidget {
  const BookReadingScreen({super.key});

  @override
  State<BookReadingScreen> createState() => _BookReadingScreenState();
}

class _BookReadingScreenState extends State<BookReadingScreen> {
  @override
  Widget build(BuildContext context) {
    const myText = """Señoras y señores,

No es fácil hablar en este momento, después de tantas horas de debate, después de haber escuchado tantos argumentos en pro y en contra del sufragio femenino. Yo, que soy una mujer, y que he sentido siempre la necesidad de luchar por los derechos de la mujer, no puedo menos que sentir una profunda emoción al verme aquí, en este Parlamento, defendiendo ante vosotros el derecho de la mujer a votar.

Sé que hay muchos que se oponen a este derecho. Dicen que la mujer no está preparada para votar, que no tiene la suficiente capacidad intelectual para comprender los problemas políticos. Dicen que la mujer es demasiado emocional, que se deja llevar por sus sentimientos y no por la razón. Dicen que el voto de la mujer destruiría la familia, que la mujer abandonaría su hogar y sus hijos para dedicarse a la política.

Yo quiero responder a todas estas objeciones. Quiero decirles que la mujer está tan preparada para votar como el hombre. Que la mujer tiene la misma capacidad intelectual que el hombre para comprender los problemas políticos. Que la mujer es tan racional como el hombre y que no se deja llevar por sus sentimientos más que el hombre. Que el voto de la mujer no destruiría la familia, sino que la fortalecería, porque la mujer aportaría a la política su visión particular, su sensibilidad y su capacidad de diálogo.

Señoras y señores, el voto de la mujer es un derecho fundamental. Es un derecho que nosotras, las mujeres, hemos luchado durante muchos años. Es un derecho que nosotras, las mujeres, merecemos.

Os pido que votéis a favor del sufragio femenino. Os pido que hagáis justicia a las mujeres. Os pido que nos deis la oportunidad de participar en la vida política de nuestro país.

Muchas gracias.""";

    return Scaffold(
      appBar: AppBar(
        title: const Text('Text Games'),
      ),
      body: SingleChildScrollView(
        child: SelectableText(
          myText,
          showCursor: true,
          scrollPhysics: ClampingScrollPhysics(),
          contextMenuBuilder: (context, editableTextState) =>
              AdaptiveTextSelectionToolbar(
            anchors: editableTextState.contextMenuAnchors,
            children: [
              InkWell(
                onTap: () {
                  String selectedText = myText.substring(
                    editableTextState.textEditingValue.selection.baseOffset,
                    editableTextState.textEditingValue.selection.extentOffset,
                  );
                  print("Your custom action goes here! $selectedText");
                },
                child: Text('Translate'),
              ),
              InkWell(
                onTap: () {
                  String selectedText = myText.substring(
                    editableTextState.textEditingValue.selection.baseOffset,
                    editableTextState.textEditingValue.selection.extentOffset,
                  );
                  print("Your custom action goes here! $selectedText");
                },
                child: Text('Copy'),
              ),
              InkWell(
                onTap: () {
                  String selectedText = myText.substring(
                    editableTextState.textEditingValue.selection.baseOffset,
                    editableTextState.textEditingValue.selection.extentOffset,
                  );
                  print("Your custom action goes here! $selectedText");
                },
                child: Text('Share'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
