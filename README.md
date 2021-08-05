# Mazak Fusion 360 Post Processor

## Disclaimer

THIS SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

**USER BEWARE!** This post processor is forked from the publicly-available, Autodesk-provided Mazak post processor in the [Autodesk Post Library](https://cam.autodesk.com/hsmposts). Neither Autodesk nor Keycult is responsible for anything resulting from the use of this post processor, the license of which is governed by the [Autodesk License and Services Agreement](https://www.autodesk.com/company/legal-notices-trademarks/software-license-agreements-legacy). 

## Overview

This post processor has been adapted by Keycult for use with an HCN-5000 horizontal machining center. Features applicable to other machine architectures may be changed or removed, and in any event, we have no way of testing them.

## TODO

[x] Tool identifiers
[x] Non-number program names
[ ] Geometry compensation (G61.1)
[x] Remove naive smoothing implementation
[ ] Re-implement G5P2 (high speed smoothing, high speed machining)
[ ] G117 simultaneous operation (spindle accel/decel, through-spindle coolant)
[ ] Output operations as local subprogram
[ ] Niagara coolant control (M130)
[ ] High pressure coolant control (M100 - M106 to set coolant pressure levels)


## Output operations as local subprogram

See fanuc.cps for reference implementation.

General strategy:
* Every section is output as a local subprogram 
* The section sets everything up, WCS/etc. and then calls into the subprogram
* We record the section into a buffer and spit them all out at the end
* If the section is a part of a pattern, only record the first instance into the subprogram, each other instance runs that same subprogram
