with open('mobile/lib/screens/home_screen.dart', 'r', encoding='utf-8') as f:
    text = f.read()

text = text.replace("import '../state/reward_state.dart';", "import '../models/reward_state.dart';")
text = text.replace("import '../widgets/subway_surfers_widgets.dart';", "import '../widgets/badges_sheet.dart';")

with open('mobile/lib/screens/home_screen.dart', 'w', encoding='utf-8') as f:
    f.write(text)

print('Updated imports successfully!')
