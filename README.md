> ⚠️ **Disclaimer:** This is a fan-made mod and **not affiliated with JPJ or any Malaysian government agency**.  
> No real vehicle data is used. Plates are generated purely based on known formatting styles for immersion and realism in Assetto Corsa.  
> This mod is for **entertainment purposes only**. Do not use for impersonation or illegal activities.

---

# 🇲🇾 Malaysian License Plate Generator for Assetto Corsa (UK/EU Styles)

A modular, customizable license plate generator made for Assetto Corsa using CSP Paintshop.  
Supports a wide variety of plate types including Malaysian EV plates, UK-styled two-liners, and EU-style one-liners.

> Built to be extensible, dev-friendly, and easily adaptable for future formats or regional styles.

---

## 📂 Features

- 🔧 **Modular + Extensible**
  Each plate is its own module with shared utilities. Add new formats easily with minimal code duplication.
  
- 🧠 **Shared Drawing Logic**  
  Common utilities live in `_shared.lua` to reduce redundancy and keep code clean.

- 🧪 **Dynamic Input Fields**  
  Real-time preview and input customization via CSP Paintshop UI.

- 📚 **Authentic Plate Logic (State + Region Aware)**  
  Prefixes, postfixes, and extra letters are based on real-world Malaysian formats:
  - Peninsular (A–T), KL (V, W), Langkawi (KV), Putrajaya (F), Sarawak (Q), Sabah (S)
  - Special plates like “PATRIOT”, “WWW”, “PERODUA” handled separately
  - Smart postfix logic per region (e.g. Sabah skips 'Z', 'Q')

## 🆕 Included Plate Types

| Format ID        | Description                     | Style                  |
|------------------|----------------------------------|------------------------|
| `EV`             | Malaysian EV plate (FE-FONT)     | EV Plate               |
| `UK_Simple`      | UK-style plate (two-liner)       | No frame               |
| `UK_Framed`      | UK-style plate (two-liner)       | Silver frame           |
| `EU_Simple`      | EU-style plate (single-line)     | Centered, no frame     |
| `EU_Framed`      | EU-style plate (single-line)     | Centered, silver frame |

## 🧰 File Structure
```
📁 Malaysia/
  📁 PlateTypes/
  ├── EV.lua
  ├── EU_Simple.lua
  ├── EU_Framed.lua
  ├── UK_Simple.lua
  ├── UK_Framed.lua
  ├── _shared.lua
  ├── EV_bg.png, EV_nm.png, etc.
📄 style.lua # Entry point that loads all plates
📄 FE-FONT.TTF # Used for EV plate text
📄 arialbd.ttf # Used by UK/EU plates
📄 calistomtitalic.ttf
```

## 🔧 How to Install

Drop the extracted folder into:

```
%localappdata%\AcTools Content Manager\Data (User)\License Plates
```

## 🎮 How to Use

1. Launch Custom Showroom
2. Go to Paintshop → License Plate
3. Select the `Malaysia` from `Style` dropdown
4. PlateDesign - e.g. EU, UK, EV, Simple, or Framed
5. plateType - Determines how the plate is generated.
    - Standard - Generate realistic Malaysia state plate
    - Special - Generate special issued JPJ plate
    - Custom - Generate plate based on user input
6. Generator - Slider to generate plate
7. Number - Slider to number for the plate, 0 = randomized
8. Custom - User's custom input

**Lost? Chill. Just [watch the 1-minute demo](https://youtu.be/ZieHsXteYko) and you’ll be vibin’.**

### Menu
<img width="747" height="219" alt="471221614-c3d4815d-11b9-4748-9d29-5f6760310803" src="https://github.com/user-attachments/assets/42aa610d-eee0-4699-89e5-4e8bd81a5432" />

## Plate Designs
### EU - Framed
<table> <tr> <td><img width="400" src="https://github.com/user-attachments/assets/088929f5-59e9-480a-bc7d-e07513033e71" /></td> <td><img width="400" src="https://github.com/user-attachments/assets/a881711a-546e-453c-bc6a-a2c9986159c9" /></td> </tr> <tr> <td><img width="400" src="https://github.com/user-attachments/assets/2214c269-1084-42e6-875b-ab7a620294ca" /></td> <td><img width="400" src="https://github.com/user-attachments/assets/ba39df23-2312-4b16-9261-cfb37eb84ec4" /></td> </tr> </table>

### EU - Simple
<table> <tr> <td><img width="400" src="https://github.com/user-attachments/assets/a482a6fd-794e-4533-9591-aa8e8f2732e2" /></td> <td><img width="400" src="https://github.com/user-attachments/assets/ab04dc3a-4574-4935-9501-36fa352c6801" /></td> </tr> <tr> <td><img width="400" src="https://github.com/user-attachments/assets/e13f9aed-700b-4f7c-a55b-ba7471d57a1e" /></td> <td><img width="400" src="https://github.com/user-attachments/assets/eaeb2bbe-6e58-4ac1-9b9e-513036f1158c" /></td> </tr> </table>

### UK - Framed
<table> <tr> <td><img width="400" src="https://github.com/user-attachments/assets/a70f6208-01ee-46f1-8c0d-281b5e17576b" /></td> <td><img width="400" src="https://github.com/user-attachments/assets/9c3939ac-8cdd-4fb3-b0cc-27c629f63210" /></td> </tr> <tr> <td><img width="400" src="https://github.com/user-attachments/assets/f323ef83-c2da-4d6b-a8e2-176fa3571aab" /></td> <td><img width="400" src="https://github.com/user-attachments/assets/044e21ca-7a35-4827-921d-c8a3d8362d84" /></td> </tr> </table>

### EV
<table> <tr> <td><img width="400" src="https://github.com/user-attachments/assets/e2b74ef1-1e6c-4e1f-bead-3d0dacf5539e" /></td> <td><img width="400" src="https://github.com/user-attachments/assets/72a59395-d5f4-40ed-8f08-a65e467f97b2" /></td> </tr> <tr> <td><img width="400" src="https://github.com/user-attachments/assets/06cc0212-0e6b-4e5c-bdf7-5a170907c8bc" /></td> <td><img width="400" src="https://github.com/user-attachments/assets/6fbf9cd6-2dab-42ba-8f81-0cd78f7c6221" /></td> </tr> </table>


---

## 🖊️ Adding New Plate Designs

1. Create a new `YourPlateName.lua` inside `PlateTypes/`
2. Define a `draw_plate()` function following existing examples
3. Add background and normal map images (e.g., `YourPlateName_bg.png`)
4. Register it in `style.lua` by loading your module

---

## To-Do:
- Fix custom mode formatting issues, the logic completely ignores any letters between spaces.
- Fix centering issue with custom mode in UK Plates(2 line plates)

## 🧾 License
**MIT License** – Free to use, reuse, remix, repost, and build on.
> Credit not required, but appreciated.  
> Just don’t try to lock it behind a paywall or pull any NFT clownery 🪦

## 🏁 Credits

Made by distrlct1. Discord: respwn3d

<!-- SEO KEYWORDS FOR DISCOVERABILITY -->
<!--
malaysia assetto corsa license plate
malaysian number plate generator ac
assetto corsa malaysia plate mod
ac csp custom plate malaysia
jpj plate assetto corsa mod
malaysian license plate generator
csp license plate malaysia mod
custom malaysia number plate ac
ev plate malaysia assetto corsa
mod plat kereta malaysia assetto corsa
malaysian car plate mod ac
assetto corsa malaysia plate script
ac custom plate paintshop malaysia
csp plate generator malaysia
mod plat EV malaysia ac
malaysia car plate customization mod
assetto corsa malaysia number plate mod
paintshop plate mod malaysia
custom license plate mod malaysia
assetto corsa my number plate
plate generator mod malaysia
jpj malaysia plate script assetto corsa
-->
