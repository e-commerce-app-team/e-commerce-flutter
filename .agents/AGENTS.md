## Exhaustive Internal Verification Before External Blame
When debugging issues involving data flow between the frontend and backend (or any external system), **never prematurely conclude that the external system is at fault without first exhaustively tracing the entire data pipeline within the primary codebase.** 
- Do not stop at inspecting the UI rendering logic or the API call definition.
- Meticulously verify all intermediate data transformations, mapping functions (e.g., `copyWith`, `fromJson`), and state management layers.
- Ensure that data is not being inadvertently dropped, overwritten, or miscast locally before assuming the backend failed to save or return it.
