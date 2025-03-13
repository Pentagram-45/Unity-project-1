using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

public class MyWindow : EditorWindow
{
    // Start is called before the first frame update
    [MenuItem("Test Menu/new window")]

    // Update is called once per frame
    static void ShowWindow()
    {
        EditorWindow.GetWindow<MyWindow>();
    }
}
