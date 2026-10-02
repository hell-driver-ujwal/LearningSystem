using System;
using System.Text;
using System.Web;

namespace LearningSystem.Helpers
{
    // Inky, the Inkwell mascot: an ink drop drawn as inline SVG so CSS can animate the eyes and arms.
    // Every pose is the same body plus a face, a pair of arms and an optional prop.
    public static class MascotHelper
    {
        // pose: wave, cheer, think, read, point, sleep, oops, search, lock, trophy, fire, graduate
        public static string Render(string pose, string label = null, string cssClass = "")
        {
            pose = String.IsNullOrEmpty(pose) ? "wave" : pose;
            StringBuilder svg = new StringBuilder();
            svg.Append("<svg class=\"inky inky-").Append(HttpUtility.HtmlAttributeEncode(pose));
            if (!String.IsNullOrEmpty(cssClass)) svg.Append(" ").Append(HttpUtility.HtmlAttributeEncode(cssClass));
            svg.Append("\" viewBox=\"0 0 160 160\" focusable=\"false\"");
            // A mascot is decoration unless the page gives it a label.
            if (String.IsNullOrEmpty(label)) svg.Append(" aria-hidden=\"true\">");
            else svg.Append(" role=\"img\" aria-label=\"").Append(HttpUtility.HtmlAttributeEncode(label)).Append("\">");
            svg.Append("<ellipse class=\"inky-shadow\" cx=\"80\" cy=\"152\" rx=\"34\" ry=\"5\"/>");
            svg.Append(BackProp(pose));
            svg.Append("<g class=\"inky-body\">");
            svg.Append("<ellipse cx=\"64\" cy=\"146\" rx=\"10\" ry=\"6\" class=\"inky-foot\"/><ellipse cx=\"96\" cy=\"146\" rx=\"10\" ry=\"6\" class=\"inky-foot\"/>");
            svg.Append("<path class=\"inky-drop\" d=\"M80 10C95 36 126 58 126 98A46 46 0 0 1 34 98C34 58 65 36 80 10Z\"/>");
            svg.Append("<path class=\"inky-shine\" d=\"M58 62C52 72 49 82 50 92\"/><circle class=\"inky-shine-dot\" cx=\"62\" cy=\"52\" r=\"3.5\"/>");
            svg.Append(Face(pose));
            svg.Append(Arms(pose));
            svg.Append("</g>");
            svg.Append(FrontProp(pose));
            return svg.Append("</svg>").ToString();
        }

        private static string Face(string pose)
        {
            StringBuilder face = new StringBuilder("<g class=\"inky-face\">");
            // Eyes: closed arcs when sleeping or very happy, otherwise big round eyes that blink.
            if (pose == "sleep")
                face.Append("<path class=\"inky-line\" d=\"M56 94q8 6 16 0M88 94q8 6 16 0\"/>");
            else if (pose == "cheer" || pose == "trophy" || pose == "graduate")
                face.Append("<path class=\"inky-line\" d=\"M56 96q8-9 16 0M88 96q8-9 16 0\"/>");
            else
            {
                string look = pose == "think" ? "-2,-3" : pose == "point" ? "3,0" : pose == "read" ? "0,3" : "0,0";
                face.Append("<g class=\"inky-eyes\"><ellipse class=\"inky-eye\" cx=\"64\" cy=\"92\" rx=\"10\" ry=\"12\"/><ellipse class=\"inky-eye\" cx=\"96\" cy=\"92\" rx=\"10\" ry=\"12\"/>");
                face.Append("<g transform=\"translate(").Append(look).Append(")\"><circle class=\"inky-pupil\" cx=\"65\" cy=\"94\" r=\"5.5\"/><circle class=\"inky-pupil\" cx=\"97\" cy=\"94\" r=\"5.5\"/>");
                face.Append("<circle class=\"inky-glint\" cx=\"67\" cy=\"91\" r=\"2\"/><circle class=\"inky-glint\" cx=\"99\" cy=\"91\" r=\"2\"/></g></g>");
            }
            if (pose == "oops" || pose == "lock") face.Append("<path class=\"inky-line\" d=\"M54 82l14-5M106 82l-14-5\"/>");
            if (pose == "think") face.Append("<path class=\"inky-line\" d=\"M56 76q8-5 16-1M88 75q8-4 16 1\"/>");
            face.Append("<ellipse class=\"inky-cheek\" cx=\"50\" cy=\"110\" rx=\"7\" ry=\"4\"/><ellipse class=\"inky-cheek\" cx=\"110\" cy=\"110\" rx=\"7\" ry=\"4\"/>");
            // Mouth
            switch (pose)
            {
                case "cheer": case "trophy": case "graduate": case "fire":
                    face.Append("<path class=\"inky-mouth\" d=\"M68 108q12 16 24 0z\"/><path class=\"inky-tongue\" d=\"M74 114q6 5 12 0q-6-3-12 0z\"/>"); break;
                case "think": face.Append("<path class=\"inky-line\" d=\"M72 114q4-3 8 0t8 0\"/>"); break;
                case "oops": case "search": face.Append("<ellipse class=\"inky-mouth\" cx=\"80\" cy=\"113\" rx=\"5\" ry=\"6\"/>"); break;
                case "sleep": face.Append("<path class=\"inky-line\" d=\"M75 113q5 3 10 0\"/>"); break;
                default: face.Append("<path class=\"inky-line\" d=\"M70 110q10 9 20 0\"/>"); break;
            }
            if (pose == "oops") face.Append("<path class=\"inky-sweat\" d=\"M118 66c3 5 5 8 5 10a5 5 0 0 1-10 0c0-2 2-5 5-10z\"/>");
            return face.Append("</g>").ToString();
        }

        private static string Arms(string pose)
        {
            const string left = "M38 108q-12 6-16 18", right = "M122 108q12 6 16 18";
            switch (pose)
            {
                case "wave": return Arm(left, "") + Arm("M122 104q14-6 18-26", "inky-wave-arm") + Hand(140, 76, "inky-wave-arm");
                case "cheer": case "trophy": return Arm("M38 102q-14-8-16-30", "inky-cheer-arm") + Hand(22, 70, "inky-cheer-arm") + Arm("M122 102q14-8 16-30", "inky-cheer-arm inky-cheer-right") + Hand(138, 70, "inky-cheer-arm inky-cheer-right");
                case "think": return Arm(left, "") + Arm("M120 110q-4 14-26 10", "") + Hand(94, 120, "");
                case "read": return Arm("M40 112q6 14 22 16", "") + Arm("M120 112q-6 14-22 16", "");
                case "point": return Arm(left, "") + Arm("M122 104q16-2 30-12", "inky-point-arm") + Hand(152, 91, "inky-point-arm");
                case "fire": case "graduate": return Arm(left, "") + Arm("M122 104q14-6 18-22", "") + Hand(140, 80, "");
                case "lock": case "search": return Arm(left, "") + Arm("M122 108q10 2 16 10", "") + Hand(139, 120, "");
                default: return Arm(left, "") + Arm(right, "");
            }
        }

        private static string Arm(string path, string cssClass)
        {
            return "<path class=\"inky-arm " + cssClass + "\" d=\"" + path + "\"/>";
        }

        private static string Hand(int x, int y, string cssClass)
        {
            return "<circle class=\"inky-hand " + cssClass + "\" cx=\"" + x + "\" cy=\"" + y + "\" r=\"6\"/>";
        }

        // Props drawn behind the body.
        private static string BackProp(string pose)
        {
            if (pose == "cheer") return "<g class=\"inky-confetti\"><rect x=\"20\" y=\"30\" width=\"8\" height=\"8\" rx=\"2\" fill=\"#ffcb47\"/><rect x=\"130\" y=\"24\" width=\"8\" height=\"8\" rx=\"2\" fill=\"#5ee4a0\" transform=\"rotate(20 134 28)\"/><circle cx=\"30\" cy=\"60\" r=\"4\" fill=\"#ff6fb5\"/><circle cx=\"140\" cy=\"52\" r=\"4\" fill=\"#5cd5ff\"/></g>";
            if (pose == "think") return "<g class=\"inky-bulb\"><circle cx=\"128\" cy=\"34\" r=\"14\" fill=\"#ffd84d\"/><rect x=\"122\" y=\"46\" width=\"12\" height=\"8\" rx=\"2\" fill=\"#c9cbe0\"/><path d=\"M128 10v-6M146 18l5-4M110 18l-5-4\" stroke=\"#ffd84d\" stroke-width=\"3\" stroke-linecap=\"round\"/></g>";
            if (pose == "sleep") return "<g class=\"inky-zzz\"><text x=\"118\" y=\"44\">z</text><text x=\"130\" y=\"30\">z</text><text x=\"142\" y=\"16\">Z</text></g>";
            return "";
        }

        // Props drawn in front of the body.
        private static string FrontProp(string pose)
        {
            switch (pose)
            {
                case "read": return "<g class=\"inky-book\"><path d=\"M50 118l30 8 30-8v26l-30 8-30-8z\" fill=\"#ff8a5c\"/><path d=\"M80 126v26\" stroke=\"#c2532c\" stroke-width=\"2\"/><path d=\"M56 124l20 5M84 129l20-5M56 132l20 5M84 137l20-5\" stroke=\"#fff3ec\" stroke-width=\"2\"/></g>";
                case "trophy": return "<g class=\"inky-trophy\"><path d=\"M66 116h28v10a14 14 0 0 1-28 0z\" fill=\"#ffcb47\"/><path d=\"M66 120h-6a6 6 0 0 0 6 8M94 120h6a6 6 0 0 1-6 8\" stroke=\"#ffcb47\" stroke-width=\"3\" fill=\"none\"/><rect x=\"76\" y=\"138\" width=\"8\" height=\"6\" fill=\"#e0a92a\"/><rect x=\"70\" y=\"143\" width=\"20\" height=\"5\" rx=\"2\" fill=\"#e0a92a\"/></g>";
                case "graduate": return "<g class=\"inky-cap\"><path d=\"M80 4l40 14-40 14-40-14z\" fill=\"#0d2a57\" stroke=\"#a5d6ff\" stroke-width=\"2\"/><path d=\"M60 24v12q20 10 40 0V24\" fill=\"#143d7a\" stroke=\"#a5d6ff\" stroke-width=\"2\"/><path d=\"M118 18v20\" stroke=\"#ffcb47\" stroke-width=\"3\"/><circle cx=\"118\" cy=\"40\" r=\"4\" fill=\"#ffcb47\"/></g>";
                case "fire": return "<g class=\"inky-flame\"><path d=\"M142 84c-14-4-18-18-10-30 2 8 6 10 10 10 0-10 4-18 12-24-2 10 6 16 6 28 0 10-8 18-18 16z\" fill=\"#ff8a3d\"/><path d=\"M144 82c-6-2-8-8-4-14 2 4 4 5 6 5 0-5 2-8 5-11 0 6 3 8 3 13 0 5-5 8-10 7z\" fill=\"#ffd84d\"/></g>";
                case "search": return "<g class=\"inky-glass\"><circle cx=\"146\" cy=\"110\" r=\"12\" fill=\"rgba(160,220,255,.25)\" stroke=\"#e8ecff\" stroke-width=\"4\"/><path d=\"M137 120l-8 10\" stroke=\"#e8ecff\" stroke-width=\"5\" stroke-linecap=\"round\"/></g>";
                case "lock": return "<g class=\"inky-lock\"><rect x=\"132\" y=\"112\" width=\"22\" height=\"18\" rx=\"4\" fill=\"#ffcb47\"/><path d=\"M137 112v-6a6 6 0 0 1 12 0v6\" stroke=\"#ffcb47\" stroke-width=\"3.5\" fill=\"none\"/><circle cx=\"143\" cy=\"121\" r=\"2.5\" fill=\"#5a4310\"/></g>";
                default: return "";
            }
        }
    }
}
