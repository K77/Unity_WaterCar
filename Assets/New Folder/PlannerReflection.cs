using System.Collections.Generic;
using UnityEngine;

public class PlannerReflection : MonoBehaviour {

    private Camera reflectionCamera = null;
    private RenderTexture reflectionRT = null;

    public Vector3 normal;
    public Vector3 seaPosition;


    private void Start()
    {
        if (reflectionCamera == null || reflectionRT == null)
        {
            var go = new GameObject("Reflection Camera");
            reflectionCamera = go.AddComponent<Camera>();
            reflectionCamera.CopyFrom(Camera.main);

            //reflectionRT = RenderTexture.GetTemporary(1024, 1024, 16, RenderTextureFormat.RInt);
            reflectionRT = RenderTexture.GetTemporary(1024, 1024, 16);

            reflectionCamera.targetTexture = reflectionRT;
            reflectionCamera.enabled = false;
            Shader.SetGlobalTexture("_ReflectionSeaTex", reflectionRT);

        }


    }

    private void OnPreRender()
    {

            UpdateCameraParams(Camera.current, reflectionCamera);

            renderReflectionCamera();

    }

    Matrix4x4 CalculateReflectMatrix(Vector3 normal, Vector3 positionOnPlane)
    {
        var d = -Vector3.Dot(normal, positionOnPlane);
        var reflectM = new Matrix4x4();
        reflectM.m00 = 1 - 2 * normal.x * normal.x;
        reflectM.m01 = -2 * normal.x * normal.y;
        reflectM.m02 = -2 * normal.x * normal.z;
        reflectM.m03 = -2 * d * normal.x;

        reflectM.m10 = -2 * normal.x * normal.y;
        reflectM.m11 = 1 - 2 * normal.y * normal.y;
        reflectM.m12 = -2 * normal.y * normal.z;
        reflectM.m13 = -2 * d * normal.y;

        reflectM.m20 = -2 * normal.x * normal.z;
        reflectM.m21 = -2 * normal.y * normal.z;
        reflectM.m22 = 1 - 2 * normal.z * normal.z;
        reflectM.m23 = -2 * d * normal.z;
         
        reflectM.m30 = 0;
        reflectM.m31 = 0;
        reflectM.m32 = 0;
        reflectM.m33 = 1;

        return reflectM;
    }

    private void UpdateCameraParams(Camera srcCamera, Camera destCamera)
    {
        if (destCamera == null || srcCamera == null)
            return;

        destCamera.clearFlags = srcCamera.clearFlags;
        destCamera.backgroundColor = srcCamera.backgroundColor;
        destCamera.farClipPlane = srcCamera.farClipPlane;
        destCamera.nearClipPlane = srcCamera.nearClipPlane;
        destCamera.orthographic = srcCamera.orthographic;
        destCamera.fieldOfView = srcCamera.fieldOfView;
        destCamera.aspect = srcCamera.aspect;
        destCamera.orthographicSize = srcCamera.orthographicSize;
    }

    private void renderReflectionCamera()
    {
        var reflectM = CalculateReflectMatrix(normal, seaPosition);
        reflectionCamera.worldToCameraMatrix = Camera.current.worldToCameraMatrix * reflectM;

        var d = -Vector3.Dot(normal, seaPosition);
        var plane = new Vector4(normal.x, normal.y, normal.z, d);
        reflectionCamera.projectionMatrix = CaculateObliqueViewFrusumMatrix(plane, reflectionCamera);

        GL.invertCulling = true;
        //reflectionCamera.RenderWithShader(Shader.Find("Unlit/PlannerReplaceShader"), "RenderType");
        reflectionCamera.Render();
        GL.invertCulling = false;
    }

    private Matrix4x4 CaculateObliqueViewFrusumMatrix(Vector4 plane, Camera camera)
    {
        var viewSpacePlane = camera.worldToCameraMatrix.inverse.transpose * plane;
        var projectionMatrix = camera.projectionMatrix;

        var clipSpaceFarPanelBoundPoint = new Vector4(Mathf.Sign(viewSpacePlane.x), Mathf.Sign(viewSpacePlane.y), 1, 1);
        var viewSpaceFarPanelBoundPoint = camera.projectionMatrix.inverse * clipSpaceFarPanelBoundPoint;

        var m4 = new Vector4(projectionMatrix.m30, projectionMatrix.m31, projectionMatrix.m32, projectionMatrix.m33);
        var u = 2.0f / Vector4.Dot(viewSpacePlane, viewSpaceFarPanelBoundPoint);
        var newViewSpaceNearPlane = u * viewSpacePlane;

        var m3 = newViewSpaceNearPlane - m4;

        projectionMatrix.m20 = m3.x;
        projectionMatrix.m21 = m3.y;
        projectionMatrix.m22 = m3.z;
        projectionMatrix.m23 = m3.w;

        return projectionMatrix;
    }
}