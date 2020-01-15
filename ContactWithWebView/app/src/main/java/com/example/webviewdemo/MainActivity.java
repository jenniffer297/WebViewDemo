package com.example.webviewdemo;

import android.content.Context;
import android.graphics.Bitmap;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;

import android.util.Log;
import android.view.View;
import android.webkit.JavascriptInterface;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.widget.Button;
import android.widget.EditText;
import android.widget.Toast;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

public class MainActivity extends AppCompatActivity {
    Button b1;
    EditText ed1;

    private WebView wv1;
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        Log.i("myLog","app onCreate");
        setContentView(R.layout.activity_main);

        b1=(Button)findViewById(R.id.button);
        ed1=(EditText)findViewById(R.id.editText);

        wv1=(WebView)findViewById(R.id.webView);
        wv1.addJavascriptInterface(new WebAppInterface(this),"Android");
        WebSettings webSettings = wv1.getSettings();
        webSettings.setJavaScriptEnabled(true);
        wv1.setWebViewClient(new MyBrowser() {
            @Override
            public void onPageStarted(WebView view, String url, Bitmap favicon) {
                Log.i("myLog", "onPageStarted:"+url);

                super.onPageStarted(view, url, favicon);
            }
        });

        b1.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                String url = ed1.getText().toString();

                wv1.getSettings().setLoadsImagesAutomatically(true);
                //wv1.getSettings().setJavaScriptEnabled(true);
                wv1.getSettings().setCacheMode(WebSettings.LOAD_DEFAULT);
                wv1.getSettings().setAppCacheEnabled(false);
                wv1.setScrollBarStyle(View.SCROLLBARS_INSIDE_OVERLAY);
                wv1.loadUrl(url);
            }
        });
    }

    private class MyBrowser extends WebViewClient {
        @Override
        public boolean shouldOverrideUrlLoading(WebView view, String url) {
            Log.i("myLog","url:"+url);
            view.loadUrl(url);
            return true;
        }
    }

    public class WebAppInterface {
        Context mContext;

        /** Instantiate the interface and set the context */
        WebAppInterface(Context c) {
            mContext = c;
        }

        /** Show a toast from the web page */
        @JavascriptInterface
        public void showToast(String toast) {
            Toast.makeText(mContext, toast, Toast.LENGTH_SHORT).show();
        }

        /** return string to js */
        @JavascriptInterface
        public String getMsg(String msg) {
            Log.i("getMsg","msg:"+msg);
            String returnMsg = "msg from android";
            return returnMsg;
        }

        /** get json data and do sign */
        @JavascriptInterface
        public String doSign(String signObj){
            Log.i("doSign","signObj:"+signObj);
            String result = "";
            Toast.makeText(mContext, signObj, Toast.LENGTH_SHORT).show();

            /** decrypt and parse json */
            try {

                JSONObject obj = new JSONObject(signObj);

                String Idno = "";
                String ToSign = "";

                try {
                    Idno = obj.getString("idno");
                    ToSign = obj.getString("toSign");

                    Log.i("doSign","idno:"+Idno+", toSign:"+ToSign);
                } catch (JSONException e) {
                    e.printStackTrace();
                }

            } catch (JSONException e) {
                Log.e("doSign","Could not convert to json");
            }


            /** do sign */

            /** return result json string */
            result = "{'code':'0000','desc':'JSON測試成功' }";
            try {
                JSONObject obj = new JSONObject(result);
                result = obj.toString();
                return result;
            } catch (JSONException e) {
                e.printStackTrace();
            }

            return result;
        }
    }
}
