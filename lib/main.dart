import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Dock(
            items: const [
              Icons.person,
              Icons.message,
              Icons.call,
              Icons.camera,
              Icons.photo,
            ],
            builder: (e) {
              return Container(
                constraints: const BoxConstraints(minWidth: 48),
                height: 48,
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.primaries[e.hashCode % Colors.primaries.length],
                ),
                child: Center(child: Icon(e, color: Colors.white)),
              );
            },
          ),
        ),
      ),
    );
  }
}

class Dock extends StatefulWidget {
  const Dock({
    super.key,
    this.items = const [],
    required this.builder,
  });

  final List<IconData> items;

  final Widget Function(IconData) builder;

  @override
  State<Dock> createState() => _DockState();
}

class _DockState extends State<Dock> {
  late final List<IconData> _items = widget.items.toList();

  final Map<IconData, Offset> _draggedItemsPosition = {};

  final Map<IconData, int> _removedItemsIndexes = {};

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Center(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.black12,
            ),
            padding: const EdgeInsets.all(4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: _items.map((item) {
                return Draggable<IconData>(
                  data: item,
                  feedback: Material(
                    color: Colors.transparent,
                    child: Container(
                      constraints: const BoxConstraints(minWidth: 48),
                      height: 48,
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.primaries[item.hashCode % Colors.primaries.length]
                            .withOpacity(0.7),
                      ),
                      child: Center(child: Icon(item, color: Colors.white)),
                    ),
                  ),
                  childWhenDragging: Container(),
                  onDraggableCanceled: (velocity, offset) {
                    setState(() {
                      _draggedItemsPosition[item] = offset;

                      int removedIndex = _items.indexOf(item);
                      _items.remove(item);
                      _removedItemsIndexes[item] = removedIndex;
                    });
                  },
                  child: DragTarget<IconData>(
                    onAccept: (data) {
                      setState(() {
                        final dragIndex = _items.indexOf(data);
                        final targetIndex = _items.indexOf(item);

                        if (dragIndex != targetIndex) {
                          final draggedItem = _items[dragIndex];
                          _items.removeAt(dragIndex);
                          _items.insert(targetIndex, draggedItem);
                        }
                      });
                    },
                    onWillAccept: (data) {
                      return true;
                    },
                    builder: (context, candidateData, rejectedData) {
                      return widget.builder(item);
                    },
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        ..._draggedItemsPosition.entries.map((entry) {
          return Positioned(
            left: entry.value.dx,
            top: entry.value.dy,
            child: Draggable<IconData>(
              data: entry.key,
              feedback: Material(
                color: Colors.transparent,
                child: Container(
                  constraints: const BoxConstraints(minWidth: 48),
                  height: 48,
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.primaries[entry.key.hashCode % Colors.primaries.length]
                        .withOpacity(0.7),
                  ),
                  child: Center(child: Icon(entry.key, color: Colors.white)),
                ),
              ),
              childWhenDragging: Container(),
              onDraggableCanceled: (velocity, offset) {
                setState(() {
                  _draggedItemsPosition[entry.key] = offset;
                });
              },
              child: DragTarget<IconData>(
                onAccept: (data) {
                  setState(() {
                    _draggedItemsPosition.remove(entry.key);

                    if (_removedItemsIndexes.containsKey(entry.key)) {
                      final originalIndex = _removedItemsIndexes[entry.key]!;
                      if (originalIndex >= 0 && originalIndex < _items.length) {
                        _items.insert(originalIndex, entry.key);
                      } else {
                        _items.add(entry.key);
                      }
                    } else {
                      _items.add(entry.key);
                    }
                  });
                },
                onWillAccept: (data) {
                  return true;
                },
                builder: (context, candidateData, rejectedData) {
                  return widget.builder(entry.key);
                },
              ),
            ),
          );
        }),
      ],
    );
  }
}
