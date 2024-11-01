package sol.terra;

import java.lang.String;
import android.content.Intent;
import android.net.Uri;

public class PlayVideo {

    public PlayVideo(){}


    public static Intent play(String url) {
        Uri uri = Uri.parse(url);
        Intent intent = new Intent(android.content.Intent.ACTION_VIEW);
        intent.setDataAndTypeAndNormalize(uri, "video/*");
        return intent;
        }

    public static Intent chooser() {
        Intent intent = new Intent(android.content.Intent.ACTION_VIEW);
        intent.setTypeAndNormalize("video/*");
        Intent chooser = Intent.createChooser(intent, "Title");
        return chooser;
        }

}
