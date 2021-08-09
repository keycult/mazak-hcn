# Mazak Fusion 360 Post Processor

## Disclaimer

THIS SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

**USER BEWARE!** This post processor is forked from the publicly-available, Autodesk-provided Mazak post processor in the [Autodesk Post Library](https://cam.autodesk.com/hsmposts). Neither Autodesk nor Keycult is responsible for anything resulting from the use of this post processor, the license of which is governed by the [Autodesk License and Services Agreement](https://www.autodesk.com/company/legal-notices-trademarks/software-license-agreements-legacy). 

## Overview

This post processor has been adapted by Keycult for use with an HCN-5000 horizontal machining center. Features applicable to other machine architectures may be changed or removed, and in any event, we have no way of testing them.

## TODO

- [x] Tool identifiers
- [x] Non-number program names
- [x] Remove naive smoothing implementation
- [ ] Geometry compensation (G61.1)
- [ ] Re-implement G5P2 (high speed smoothing, high speed machining)
- [ ] G117 simultaneous operation (spindle accel/decel, through-spindle coolant)
- [ ] Niagara coolant control (M130)
- [ ] High pressure coolant control (M100 - M106 to set coolant pressure levels)

## Post properties

| Property | Group | Description | Values |
| --- | --- | --- | --- |
| Example property | Formatting | This is an example description | True (default) or False |

---

### Formatting

#### Example property

This is an example of a property description. Doing it like this is a bit better maybe.

It allows me to go onto another line which is kinda nice.

**Values:**

+ True *
+ False

#### Another example property

This is what a second one would look like. 

**Values:**

+ True
+ False *