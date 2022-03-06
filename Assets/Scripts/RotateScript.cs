using UnityEngine;

public class RotateScript : MonoBehaviour {
  [Range(0,360)]
  public float rotationSpeed = 50f;
  public bool rotating = false;

  private Quaternion originalRotation;

  private void Start() {
    originalRotation = transform.localRotation;
  }

  void Update() {
    if (rotating) {
      transform.Rotate(0, 0, Time.deltaTime * -rotationSpeed);
    }
  }

  public void ResetRotation() {
    transform.localRotation = originalRotation;
  }
}
